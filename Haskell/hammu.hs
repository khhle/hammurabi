import System.Random  
import Control.Monad
import Data.Char

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
getHarvest :: Int -> Int -> Int
getHarvest nSeed land = do
	let chance = (generateRandom 100 6) + 1
	((nSeed * chance) * land) `div` 1000
	
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
		
runGame:: Int -> (Int, Int, Int) -> IO ()
runGame 11 _ = putStrLn "You Win!"
runGame t (f, p, l) = do
	let	priceOfLand = getNewPrice 1
	putStrLn "-------------------------------------------"
	putStrLn ("Year: " ++ show t)
	putStrLn ("Acres of land: " ++ show l)
	putStrLn ("Population: " ++ show p)
	putStrLn ("Stored grain: " ++ show f)
	putStrLn ("Price of land: " ++ show priceOfLand)
	putStrLn ""
	putStrLn "How many acres do you wish to buy (Negative to sell)?"  
	nLandString <- getLine
	let nLand = read nLandString :: Int --convert string -> int
	putStrLn "How many bushels do you wish to feed your people?"
	nFoodString <- getLine
	let nFood = read nFoodString :: Int --convert string -> int
	putStrLn "How many acres do you wish to plant with seed?"
	nSeedString <- getLine
	let nSeed = read nSeedString :: Int --convert string -> int
	let currentFood = f - nLand * priceOfLand 
	let newLand = l + nLand
	let starvingNumber = getStarvingDeath p nFood
	let	immigrantNumber = getImmigrant l currentFood p starvingNumber
	let	plagueNumber = getPlagueDeath p
	let	harvestNumber = getHarvest nSeed newLand
	let	newPopulation = p - plagueNumber - starvingNumber + immigrantNumber
	let	tempFood = currentFood + harvestNumber - nSeed
	let	ratNumber = getEatenByRat tempFood
	let	newFood = tempFood - ratNumber
	putStrLn ""
	putStrLn "O great Hammurabi!"
	putStrLn ("You are in year " ++ show (t + 1) ++ " of your ten year rule.")
	putStrLn ("In the previous year " ++ show starvingNumber ++ " people starved to death.")
	putStrLn ("In the previous year " ++ show immigrantNumber ++ " people entered the kingdom.")
	when (plagueNumber > 0) $ putStrLn "The plague killed half the people."
	putStrLn ("The population is now " ++ show newPopulation)
	putStrLn ("We harvested " ++ show harvestNumber ++ " bushels.")
	putStrLn ("Rats destroyed " ++ show ratNumber ++ " bushels, leaving " ++ show newFood ++ " bushels in storage.")
	putStrLn ("The city owns " ++ show newLand ++ " acres of land.")
	let uprisingCount = starvingNumber `div` p
	if ( newPopulation == 0) then putStrLn "What a terrible ruler; you have no people left to rule!"
		else if ( starvingNumber > (45 `div` 100)) then putStrLn "The remaining population has overthrown you and you have been declared the worst King in history!"
			else runGame (t+1) (newFood, newPopulation, newLand)

-- IO handle could only be handle in main...
-- 
main = do  
	runGame 1 (2800, 100, 1000)
	putStrLn "GAME OVER"