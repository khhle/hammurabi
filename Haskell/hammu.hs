import System.Random  
import Data.Char

population_default	= 100
land_default = 1000
food_default = 2800
price_default = 20


-- Generate random number from 0 - range
-- input: seed and range boundary
-- imperfection, will produce the same number if passing the same seed
-- http://stackoverflow.com/questions/7980009/random-number-generator-in-haskell
generateRandom :: Int -> Int -> Int
generateRandom seed range =  head (randomRs (0, range) . mkStdGen $ seed)


--Each year, there is a 15% chance of a horrible plague. 
--When this happens, half your people die. 
--Return the number of plague deaths	
getPlagueDeath :: Int -> Int
getPlagueDeath currentPopulation = do
	let chance = generateRandom 100 6
	if(chance == 0)
		then quot currentPopulation 2
		else 0

		
--Each person needs 20 bushels of grain to survive. 
--If you feed them more than this, they are happy, but the grain is still gone. You don't get any benefit from having happy subjects. 
--Return the number of deaths from starvation (possibly zero).		
getStarvingDeath :: Int -> Int -> Int
getStarvingDeath currentPopulation nFood = do
	let numberFeedPeople = quot nFood 20
	if(numberFeedPeople > currentPopulation)
		then 0
	else currentPopulation - numberFeedPeople


	
--Nobody will come to the city if people are starving. 
--If everyone is well fed, compute how many people come to the city as: 
--(20 * number of acres you have + amount of grain you have in storage) / (100 * population) + 1.
getImmigrant :: Int -> Int -> Int -> Int -> Int
getImmigrant currrentLand currentFood currentPopulation starvingNumber = do
	if(starvingNumber > 0)
		then 0
	else do
		let a = 20*currrentLand + currentFood
		let b = 100* currentPopulation
		quot a b + 1
		

--Choose a random integer between 1 and 6, inclusive.
--Each acre that was planted with seed will yield this many bushels of grain. 
--(Example: if you planted 50 acres, and your number is 3, you harvest 150 bushels of grain). 
--Return the number of bushels harvested.
getHarvest :: Int -> Int
getHarvest nSeed = do
	let chance = (generateRandom 100 6) + 1
	nSeed * chance
	
--There is a 40% chance that you will have a rat infestation. 
--When this happens, rats will eat somewhere between 10% and 30% of your grain. 
--Return the amount of grain eaten by rats (possibly zero).
getEatenByRat :: Int -> Int
getEatenByRat currentFood = do
	let chance = generateRandom 100 3
	if(chance == 0)
		then do
			let chanceEaten = (generateRandom 100 3) + 1
			let a = quot chanceEaten 10
			currentFood * a
		else 0

--The price of land is random, and ranges from 17 to 23 bushels per acre. 
--Return the new price for the next set of decisions the player has to make.
getNewPrice :: Int -> Int
getNewPrice currentPrice = do
	let chance = generateRandom 100 6
	chance + 17

	
-- should be update every turn
-- input: 4 old variables from previous year, 3 input variables from user
-- ouput (testing): string show some important variables' value 
-- output: should be a list or something so that Main() could use it in a loops. 
-- 			or anything... 
updatePlayer :: Int -> Int -> Int -> Int -> Int -> Int -> Int -> String
updatePlayer oldPopulation oldLand oldFood oldPrice nLand nFood nSeed = do
	let currentFood2 = oldFood - nFood - nSeed
	let	currentLand2 = oldLand + nLand
	-- I have to re-create new variable multiple times (like currentFood2, currrentFood3...)
	-- because i don't think haskell let us overwrite variable, maybe... 
	if(nLand > 0)
		then do 
			let currentFood3 = currentFood2 - nLand * oldPrice -- this line make the whole code look ugly
			let starvingNumber = getStarvingDeath oldPopulation nFood
			let	immigrantNumber = getImmigrant oldLand currentFood3 oldPopulation starvingNumber
			let	plagueNumber = getPlagueDeath oldPopulation
			let	harvestNumber = getHarvest nSeed
			let	currentPopulation2 = oldPopulation - plagueNumber
			let	currentPopulation3 = currentPopulation2 - starvingNumber
			let	currentPopulation4 = currentPopulation3 + immigrantNumber
			let	currentFood4 = currentFood3 + harvestNumber
			let	ratNumber = getEatenByRat currentFood4
			let	currentFood5 = currentFood4 - ratNumber
			let	priceOfLand2 = getNewPrice oldPrice
			show ("Population: " ++	show currentPopulation4 ++ " Land: " ++ show currentLand2 ++ " Food: " ++ show currentFood5 ++ " Price: " ++ show priceOfLand2)
		else do
			let currentFood3 = currentFood2 + nLand * oldPrice -- this line make the whole code look ugly
			let starvingNumber = getStarvingDeath oldPopulation nFood
			let	immigrantNumber = getImmigrant oldLand currentFood3 oldPopulation starvingNumber
			let	plagueNumber = getPlagueDeath oldPopulation
			let	harvestNumber = getHarvest nSeed
			let	currentPopulation2 = oldPopulation - plagueNumber
			let	currentPopulation3 = currentPopulation2 - starvingNumber
			let	currentPopulation4 = currentPopulation3 + immigrantNumber
			let	currentFood4 = currentFood3 + harvestNumber
			let	ratNumber = getEatenByRat currentFood4
			let	currentFood5 = currentFood4 - ratNumber
			let	priceOfLand2 = getNewPrice oldPrice
			show ("Population: " ++	show currentPopulation4 ++ " Land: " ++ show currentLand2 ++ " Food: " ++ show currentFood5 ++ " Price: " ++ show priceOfLand2)
		
runGame:: Int -> (Int, Int, Int) -> IO ()
runGame 11 _ = putStrLn "You Win!"
runGame t (f, p, l) = do
		putStrLn "How many acres do you wish to buy (Negative to sell)?"  
		nLandString <- getLine
		let nLand = read nLandString :: Int --convert string -> int
		putStrLn "How many bushels do you wish to feed your people?"
		nFoodString <- getLine
		let nFood = read nFoodString :: Int --convert string -> int
		putStrLn "How many acres do you wish to plant with seed?"
		nSeedString <- getLine
		let nSeed = read nSeedString :: Int --convert string -> int
		runGame (t+1) (2800, 100, 1000)

-- IO handle could only be handle in main...
-- 
main = do  
	putStrLn "-------------------------------------------"
	putStrLn "Year: 1"
	putStrLn "Acres of land: 1000"
	putStrLn "Population: 100"
	putStrLn "Stored grain: 2800"
	putStrLn "Price of land: 20"
	putStrLn ""
	runGame 1 (2800, 100, 1000)
	--putStrLn $ "Report= " ++ abc 		-- putStrLn only accept String variable



