local replicatedStorage = game:GetService('ReplicatedStorage')
local sss = game:GetService('ServerScriptService')
local common = require(sss.commonModuleScript)

local closeDistance = 17 -- emergency distance
local farDistance = 30
local seeDistance = 60 -- jak daleko vidi npc (jenom pouzito jako limit v humanoidDegrees)
local veryCloseDistance = 10

local treeEvent = sss.events.treeEvent
local targetsFunc = sss.events.targetsFunc
local centralFunc = replicatedStorage.events.centralFunc

local tree = {}

tree.__index = tree

-- global

tree.nodeHash = {} -- drzi uzle -> celkem nedůležitý, pouze na visualizaci stromu
tree.modelHash = {}

tree.index = 1
tree.modelIndex = 1

tree.queueFlag = false -- pokud se prave procesuje neco v newInstance
tree.queue = {}
tree.queueIndex = 1

-- local

local data = {}

data.players = {'players', {}} -- mezilist pouzity ke storovani temp infa (kdyz je for loop na targets)
data.answer = {'answer', 'no'}

data.firstFlag = {'firstFlag', false} -- pri prvni iteraci run se musi updatovat playerTargets
data.recursionFlag = {'recursionFlag', false} -- na zastaveni recurse v run
data.killFlag = {'killFlag', false} -- pokud se neco neobvykle posere -> komplet reset az k looking for player
data.huntFlag = {'huntFlag', false} -- pokud je forced hunt
data.showdownEnum = {'showdownEnum', 'inactive'} -- pokud je npc v showdownu (kontrola while loopu v emergency)
data.runningEnum = {'runningEnum', 'inactive'} -- pokud je zrovna run aktivni + pokud npc umrelo

-- po tom az bude tohle funkcni, tak otestovat jestli se targets ve run spravne updatuji
-- otestovat jestli vsechny edge case veci funguji (killFlag)

-- udelat neco jako mainTarget
-- upravit distance -> showzonestart je uz od 15
-- udelat bakcstep vic likely + dat rotate pred backstepem?

-- predelat kdy se ma lunge check firovat (pri showdown a pri huntu kdyz se circuluje?)
-- mel by se showdown enum vypinat po zapnuti huntFlag (otestovat)?

-- main funkce


function tree.newInstance()
	-- vytvoreni nove instance do modelHash
	
	tree.queueFlag = true
	local namer = tree.queue[tree.queueIndex]
	local obj = {}
	
	tree.modelHash[tree.modelIndex] = {}
	tree.modelHash[tree.modelIndex]['name'] = namer
	tree.modelHash[tree.modelIndex]['targets'] = {}
	tree.modelHash[tree.modelIndex]['modelData'] = {}
	
	for i, thing in pairs(data) do
		tree.modelHash[tree.modelIndex]['modelData'][thing[1]] = thing[2]
	end
	
	obj.index = tree.modelIndex
	
	tree.modelIndex = tree.modelIndex + 1
	tree.queueIndex = tree.queueIndex + 1
	
	if tree.queueIndex > #tree.queue then
		tree.queue = {}
		tree.queueIndex = 1
		tree.queueFlag = false
	end
	
	tree.queueFlag = false
	return obj
end


function tree.instanceQueue(namer)
	-- fronta na newInstance()
	
	table.insert(tree.queue, namer)
	local current = #tree.queue
	
	if not tree.queueFlag then
		return tree.newInstance()
	else
		while true do
			if tree.queueIndex == current then
				return tree.newInstance()
			end
			task.wait(0.1)
		end
	end
end


function tree.new(val, id, arg1)
	-- vytvoreni noveho uzlu
	
	local obj = {}
	
	obj.func = val
	obj.parent = nil
	obj.children = {}
	obj.id = id
	obj.index = tree.index
	
	obj.arg1 = arg1
	
	setmetatable(obj, tree)
	
	tree.nodeHash[tree.index] = obj
	tree.index = tree.index + 1
	return obj
end


function tree:setChildren(childer)
	-- spojovani uzlu
	
	for i, kid in pairs(childer) do
		table.insert(self.children, kid.index)
		kid.parent = self.index
	end
end


function tree.run(index, node)
	-- hlavi smycka celeho module scriptu
	
	local hash = tree.modelHash[index]
	local modelData = hash['modelData']
	modelData.answer = nil
	
	if not modelData.firstFlag then
		modelData.firstFlag = true
		modelData.killFlag = false
		hash.targets = targetsFunc:Invoke(tree.modelHash[index].name)
		node = tree.nodeHash[1]
	end
	
	if node.index == 1 and modelData.runningEnum ~= 'dead' then modelData.runningEnum = 'active' end
	
	local nohash = tree.nodeHash
	local result = nil
	
	if modelData.killFlag and node.index == 1 then
		return 'kill'
	elseif modelData.aliveFlag then
		if node.index == 1 then
			tree.modelHash[index] = nil
		end
		
		return
	end
	
	if node.func then
		result = node.func(index, node.arg1)
	end
	
	if result == 'end' then modelData.recursionFlag = true return modelData.answer end
	
	for i, kid in pairs(node.children) do
		if result == nohash[kid].id or nohash[kid].id == nil then
			tree.run(index, nohash[kid])
		end
	end
	
	if node.index == 1 then
		if modelData.runningEnum == 'dead' then
			modelData.runningEnum = 'done'
			return
		else
			modelData.runningEnum = 'inactive'
		end
		modelData.recursionFlag = false
		modelData.firstFlag = false
	end
	
	if modelData.killFlag then return 'kill' end
	return modelData.answer
end


function tree.emergency(index)
	-- kdyz je potreba rychla reakce na vnejsi podnety
	
	local function reset()
		tree.modelHash[index].modelData.showdownEnum = 'inactive'
	end
	
	while tree.modelHash[index].modelData.showdownEnum ~= 'stop' do
		
		local tristance, targetHrp = math.huge, nil
		
		for i, player in pairs(tree.modelHash[index].targets) do
			
			local char, hrp, humanoid = common.getChar(player, 'player')
			local model = workspace:FindFirstChild(tree.modelHash[index].name)
			
			if not char or not model then continue end
			
			local distance = (hrp.Position - model.PrimaryPart.Position).Magnitude
			
			if distance < tristance then
				tristance = distance
				targetHrp = hrp
			end
			
			model, char, hrp, humanoid = nil
		end
		print(tristance)
		if tristance <= veryCloseDistance then
			if math.random(1,2) == 1 then
				treeEvent:Fire(tree.modelHash[index].name, 'backstep', true, targetHrp)
			else
				treeEvent:Fire(tree.modelHash[index].name, 'hunt', true, targetHrp)
				tree.modelHash[index].modelData.huntFlag = true
			end
			
			reset()
			return
		elseif tristance < closeDistance then
			local randint = math.random(1, 10)
			
			if randint <= 5 then
				treeEvent:Fire(tree.modelHash[index].name, 'backstep', true, targetHrp)
			else
				treeEvent:Fire(tree.modelHash[index].name, 'hunt', true, targetHrp)
				tree.modelHash[index].modelData.huntFlag = true
			end
			
			reset()
			return
		end
		
		task.wait(0.2)
	end
	
	reset()
end


function tree.flagChange(index, flag, bool)
	-- zmena vlajky
	
	local short = tree.modelHash[index].modelData
	if flag == 'huntFlag' then
		short.huntFlag = bool
		if bool then
			if short.showdownEnum == 'active' then
				short.showdownEnum = 'stop'
			end
		end
	elseif flag == 'showdownEnum' then
		
		if bool and short.showdownEnum == 'inactive' then
			short.showdownEnum = 'active'
			task.spawn(function()
				tree.emergency(index)
			end)
		elseif not bool and short.showdownEnum == 'active' then
			short.showdownEnum = 'stop'
		end
		
	else
		warn('unknown flag: ', flag)
	end
end


function tree.modelDeath(index)
	-- cleanup po smrti npc
	
	local short = tree.modelHash[index].modelData
	
	if short.runningEnum == 'active' then
		short.runningEnum = 'dead'
		
		while short.runningEnum == 'dead' do
			task.wait(0.1)
		end
	end
	
	tree.modelHash[index] = nil
end


-- node funkce


function tree.IsFacing(index)
	-- checkuje pokud se hrac diva na npc
	
	local hash = tree.modelHash[index]
	for i, player in pairs(hash.targets) do
		local result = nil
		
		local succes, err = pcall(function()
			result = centralFunc:InvokeClient(player, hash.name, seeDistance)
		end)
		
		if not succes then warn(err) continue end
		
		if result then
			table.insert(hash.modelData.players, player)
		end
	end
	
	if hash.modelData.players[1] then
		hash.modelData.players = {}
		return true
	end
	
	return false
end


function tree.lungeCheck(index, distance)
	-- ohodnoti situaci, jestli je spravna chvile na lunge
	
	if distance < farDistance then
		local randint = math.random(1,12)
		
		if randint == 4 then
			return tree.lunge(index)
		end
	end
	
	return
end


function tree.distanceCheck(index)
	-- vypocitava vzdalenost od hracu -> reaguje podle nejnizsi vzdalenosti
	
	local hash = tree.modelHash[index]
	local tristance = math.huge
	local model = workspace:FindFirstChild(hash.name)
	
	if not model then warn'no model' hash.modelData.killFlag = true return end
	
	for i, player in hash.targets do
		local character, hrp, humanoid = common.getChar(player, 'player')
		if not character then continue end
		
		local distance = (hrp.Position - model.PrimaryPart.Position).Magnitude
		
		if distance < tristance then
			tristance = distance
		end
	end
	
	if tristance > closeDistance then
		local result = tree.lungeCheck(index, tristance)
		if result then
			return result
		else
			return false
		end
	elseif tristance < farDistance then
		return true
	end
end


function tree.hunt(index)
	tree.modelHash[index].modelData.answer = 'hunt'
	return 'end'
end


function tree.showdown(index)
	tree.modelHash[index].modelData.answer = 'showdown'
	return 'end'
end


function tree.lunge(index)
	tree.modelHash[index].modelData.answer = 'lunge'
	return 'end'
end


function tree.backstep(index)
	tree.modelHash[index].modelData.answer = 'backstep'
	return 'end'
end


-- side funkce


function tree.printTree(node)
	print(node.index, node.id, tree.nodeHash[node.parent].index)
	
	for i, kid in pairs(node.children) do
		tree.printTree(tree.nodeHash[kid])
	end
end


-- node creation


tree.root = tree.new(nil, nil)

tree.playerFacing = tree.new(tree.IsFacing, nil)
tree.root:setChildren({tree.playerFacing})

tree.sprint = tree.new(tree.hunt, false)
tree.reallyClose = tree.new(tree.distanceCheck, true)
tree.playerFacing:setChildren({tree.sprint, tree.reallyClose})

tree.showdown = tree.new(tree.showdown, false)
tree.reallyClose:setChildren({tree.showdown}, true)


return tree
