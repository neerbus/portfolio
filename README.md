# portfolio
NPC.lua 
 

Kontext projektu:  

Tento projekt bude horror-akční hra. Snažíme se o hru, která bude mít děsivou atmosféru, ale hráči budou mít k dispozici zbraně k sebe obraně. Možnost sebe obrany ubírá na strašidelnosti, a proto se snažím vytvořit npc systém, který by i přes zbraně byl stále děsivý a těžký k poražení. Zde popisuje jednu verzi tohoto systému, na které jsem pracoval pár měsíců. Tento projekt je stále v brzké fázi vytváření, takže ještě hodně plánuju a některé věci se mohou změnit. Zde jsou také zmíněna jměna jako showdow, hunt atd., to jsou jména útoků nebo chování npc.

Účel popisovaného programu:  

Jedná se o program, ve kterém se hodnotí okolní podněty. Program poté pošle výsledek do druhého programu, který daný příkaz udělá.  

Jak program funguje: 

 Celý program je jeden velký rozhodovací strom (behavior tree), ve kterém každý uzel má svojí funkci, svoje děti a “id”. Když přijde řada na nějaký uzel, tak se vykoná jeho funkce a získá se výsledek. Po získání se výsledek porovná s “id” dětí uzlu a pokud se shodují tak se dále pokračuje s tímto uzlem (rekurzivní volání). Program končí, když se najde “odpověď”. Potom už se ukončí rekurze a odpověď se pošle do 2. programu. Jsou zde 2 programy -> 1. (tento) hodnotí situaci a informuje 2. program + je to jenom jeden program, který používá každé npc, 2. program je personální pro každé npc a vykonává příkazy. Jak již bylo řečeno, tento program používají všechna npc, takže jsem musel udělat systém k odlišení -> slovník modelHash.  

Stručný popis funkcí a slovníků:  

modelHash: slovník, který obsahuje informace o npc - jméno, osobní proměnné atd. 

instanceQueue(): Frontu na vytvoření informací ve slovníku. 

newInstance(): zadání informací do modelHash. 

new(): vytvoření nového uzle. 

setChildren(): vytváření propojení mezi uzly. 

run(): nejdůležitější funkce programu -> volá funkce uzlu, hledá mezi dětmi stejné “id” a posílá odpověď do 2. programu. Je vždy volána rekursivně. 

emergency(): obsahuje hodně reaktivní smyčku, které slouží k rychlé reakci na nečekaný podnět (run se nevolá dostatečně rapidně k rychlé reakci) -> pozastaví celý 2. program, aby vykonal reakci na podnět. 

flagChange(): mění společné proměnné mezi oba programy (proměnné uložené v modelHash). 

modelDeath(): odstranění informací z modelHash po smrti npc. 

Další funkce už jsou pouze od uzlů -> např. “dívá se hráč na npc?” nebo “jak daleko je hráč” 

 

Plán do budoucna:  

Npc neumí reagovat na více hráčů  

Npc není dobře vybalancováno (moc agresivní) 

Chtělo by to udělat rozhodovací strom víc komplexní 

Chybí dodělat několik malých detailů 

 

Na vývoji tohoto programu bylo nejtěžší kontrolovat rekurzi stromu + ovládání rekurze. Při vývoji se také dost vyskytli menší chyby, které se těžce hledali. Vývoj byl celkem obtížný kvůli své abstrakci. Teď to celkem funguje, ale ještě je toho dost na udělání. 


 
LEETCODE.py 

 

Popis problému:  

Máme daný spojový seznam (linked list) a číslo k. Naším úkolem je otočit uzly spojového seznamu po skupinách k. Pokud zůstane méně než k uzlů na konci seznamu, mají zůstat stejné. 

Stručný popis řešení: 

 začneme procházet seznamem díky smyčce a ukládáme uzly do normálního seznamu. Až je délka normálního seznamu rovná k, pak jdeme přes normální list pozpátku a mění propojení daných uzlů. Potom vše propojíme k ostatním uzlům, a tak pokračujeme až do konce seznamu. Je zde samozřejmě hodně chytáků jako např. poslední uzel musí být správně připojen po otečení atd. 

Tento problém je zatím můj nejtěžší a podařilo se mi ho vyřešit za hodinu. Setkal jsem se s divnými chybami jako MLE (moc použité paměti) se kterýma jsem si moc nevěděl rady, ale nakonec jsem to pochopil. 

Statistiky:  

runtime O(N) - 100%, memory O(k) - 86% 
