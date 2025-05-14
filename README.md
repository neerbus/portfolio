# portfolio
Kontext projektu: Tento projekt bude horror-akční hra. Snažíme se o hru, která bude mít děsivou atmosféru, ale hráči budou mít k dispozici zbraně k sebe obraně. Možnost sebe obrany ubírá na strašidelnosti, a proto se snažím vytvořit npc systém, který by i přes zbraně byl stále děsivý a těžký k poražení. Zde popisuje jednu verzi tohoto systému, na které jsem pracoval pár měsíců. Tento projekt je stále v brzké fázi vytváření, takže ještě hodně plánuju a některé věci se mohou změnit. 

Účel popisovaného programu: Jedná se o program, ve kterém se hodnotí okolní podněty. Program poté pošle výsledek do druhého programu, který daný příkaz udělá.  

Jak program funguje: Celý program je jeden velký rozhodovací strom (behavior tree), ve kterém každý uzel má svojí funkci, svoje děti a “id”. Když přijde řada na nějaký uzel, tak se vykoná jeho funkce a získá se výsledek. Po získání se výsledek porovná s “id” dětí uzlu a pokud se shodují tak se dále pokračuje s tímto uzlem (rekurzivní volání). Program končí, když se najde “odpověď”. Potom už se ukončí rekurze a odpověď se pošle do 2. programu. Jsou zde 2 programy -> 1. (tento) hodnotí situaci a informuje 2. program + je to jenom jeden program, který používá každé npc, 2. program je personální pro každé npc a vykonává příkazy. Jak již bylo řečeno, tento program používají všechna npc, takže jsem musel udělat systém k odlišení -> slovník modelHash.  

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
