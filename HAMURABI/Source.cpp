#define _CRT_SECURE_NO_WARNINGS 1 


#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <iostream>
#include <iomanip>
#include <sstream>
#include <time.h>

using namespace std;

#define POPULATION_DEFAULT 100
#define LAND_DEFAULT 1000
#define FOOD_DEFAULT 2800
#define PRICE_DEFAULT 20




class Player
{
private:
	int yearNumber;
	int population;
	int land;
	int food;
	int priceOfLand;

	int starvingNumber;
	int immigrantNumber;
	int plagueNumber;
	int harvestNumber;
	int ratNumber;

public:
	Player();
	Player(int nyearNumber, int npopulation, int nland, int nfood, int npriceOfLand);

	//Getter for variables
	int getYearNumber(){ return yearNumber; }
	int getPopulation(){ return population; }
	int getLand(){ return land; }
	int getFood(){ return food; }
	int getPriceOfLand(){ return priceOfLand; }

	int getStarvingNumber(){ return starvingNumber; }
	int getImmigrantNumber(){ return immigrantNumber; }
	int getPlagueNumber(){ return plagueNumber; }
	int getHarvestNumber(){ return harvestNumber; }
	int getRatNumber(){ return ratNumber; }

	//Setter for variables
	void setYearNumber(int n){ yearNumber = n; }
	void setPopulation(int n){ population = n; }
	void setLand(int n){ land = n; }
	void setFood(int n){ food = n; }
	void setPriceOfLand(int n){ priceOfLand = n; }


	void printPlayer();	//print player's variables
	void printReport();
	bool updatePlayer(int nLand, int nFood, int nSeed); //update every turns then call printReport
	
	int getPlagueDeath();				//calculate how many people die by plague
	int getStarvingDeath(int nFood);	//calculate how many people die by starving
	bool isUprising();	//return true if people want to uprising
	int getImmigrant();					//calculate how many new people enter
	int getHarvest(int nSeed);			//calculate how much we harvest
	int getEatenByRat();				//calculate how much rat has eaten
	int getNewPrice();					//calculate new price for land
};

//Default Constructor
Player::Player(int nyearNumber, int npopulation, int nland, int nfood, int npriceOfLand)
{
	yearNumber = nyearNumber;
	population = npopulation;
	land = nland;
	food = nfood;
	priceOfLand = npriceOfLand;
}

//Print player's variable
void Player::printPlayer()
{
	cout << "-------------------------------------------" << endl;
	cout << setw(25) << "Year: "			<< yearNumber	<< endl;
	cout << setw(25) << "Acres of land: "	<< land			<< endl;
	cout << setw(25) << "Population: "		<< population	<< endl;
	cout << setw(25) << "Stored grain: "	<< food			<< endl;
	cout << setw(25) << "Price of land: "	<< priceOfLand	<< endl;
	cout << endl;
	

}

//Print the report after each turn
void Player::printReport()
{
	cout << endl;
	cout << "O great Hammurabi!" << endl;
	cout << "You are in year " << yearNumber << " of your ten year rule." << endl;
	cout << "In the previous year " << starvingNumber << " people starved to death." << endl;
	cout << "In the previous year " << immigrantNumber << " people entered the kingdom." << endl;
	if (plagueNumber > 0)
		cout << "The plague killed half the people." << endl;
	cout << "The population is now "<< population << endl;
	cout << "We harvested " << harvestNumber << " bushels." << endl;
	cout << "Rats destroyed " << ratNumber << " bushels, leaving " << food << " bushels in storage." << endl;
	cout << "The city owns " << land << " acres of land." << endl;
	cout << "Land is currently worth "<<  priceOfLand << " bushels per acre." << endl;


}

//Each year, there is a 15% chance of a horrible plague. 
//When this happens, half your people die. 
//Return the number of plague deaths
int Player::getPlagueDeath()
{
	int chance = (int)(rand() % 6);
	if (chance == 0)
		return population / 2;
	else
		return 0;
}

//Each person needs 20 bushels of grain to survive. 
//If you feed them more than this, they are happy, but the grain is still gone. You don't get any benefit from having happy subjects. 
//Return the number of deaths from starvation (possibly zero).
int Player::getStarvingDeath(int nFood)
{
	int numberFeedPeople = nFood / 20;
	if (numberFeedPeople > population)
		return 0;
	else
		return population - numberFeedPeople;
	
}

//Return true if more than 45% of the people starve. 
//(This will cause you to be immediately thrown out of office, ending the game.)
bool Player::isUprising()
{
	
	float percentStarving = (float)starvingNumber / population;
	if (percentStarving > 0.45)
		return true;
	else
		return false;
}

//Nobody will come to the city if people are starving. 
//If everyone is well fed, compute how many people come to the city as: 
//(20 * number of acres you have + amount of grain you have in storage) / (100 * population) + 1.
int Player::getImmigrant()
{
	if(getStarvingNumber() > 0)
	{
		return 0;
	}

	return (20 * land + food) / (100 * population) + 1;
}

//Choose a random integer between 1 and 6, inclusive.
//Each acre that was planted with seed will yield this many bushels of grain. 
//(Example: if you planted 50 acres, and your number is 3, you harvest 150 bushels of grain). 
//Return the number of bushels harvested.
int Player::getHarvest(int nSeed)
{
	float landChance = land / 1000.0;
	float chance = (int)(rand() % (6)) + 1;
	chance = chance * landChance;
	

	return (int) (nSeed * chance);
}


//There is a 40% chance that you will have a rat infestation. 
//When this happens, rats will eat somewhere between 10% and 30% of your grain. 
//Return the amount of grain eaten by rats (possibly zero).
int Player::getEatenByRat()
{
	
	int chance = (int)(rand() % 3);
	if (chance == 0)
	{
		int chanceEatAmount = (int)(rand() % 3) + 1;
		int foodEaten = food * ((float)chanceEatAmount / (float) 10);
		return foodEaten;
	}
	else
		return 0;
}


//The price of land is random, and ranges from 17 to 23 bushels per acre. 
//Return the new price for the next set of decisions the player has to make.
int Player::getNewPrice()
{
	
	int chance = (int)(rand() % 6);
	return chance+17;
}

//update on every turn
//
bool Player::updatePlayer(int nLand, int nFood, int nSeed)
{
	//update the remaining stats first, then calculate all the random elements
	food -= nFood;
	food -= nSeed;
	land += nLand;

	food -= nLand * priceOfLand;

	starvingNumber = getStarvingDeath(nFood);
	immigrantNumber = getImmigrant();
	plagueNumber = getPlagueDeath();
	harvestNumber = getHarvest(nSeed);

	population -= plagueNumber;
	population -= starvingNumber;

	population += immigrantNumber;

	food += harvestNumber;
	ratNumber = getEatenByRat();
	food -= ratNumber;

	priceOfLand = getNewPrice();
	
	yearNumber++;

	if(population <0)
		population = 0;

	return true;
}

//Helper function to get input and validate 
void getInput(Player* myPlayer);

//Helper function that checks if the player has lost
bool checkEndGame(Player* myPlayer);

void main()
{
	//seed random for better randomness
	srand(time(0));

	Player* myPlayer = new Player(1, POPULATION_DEFAULT, LAND_DEFAULT, FOOD_DEFAULT, PRICE_DEFAULT);
	myPlayer->printPlayer();
	bool winner = true;
	//loop for 10 years
	for (int i = 0; i < 10; i++)
	{
		getInput(myPlayer);
		cout << endl;
		if (checkEndGame(myPlayer))
		{
			winner = false;
			cout << setw(40) << "GAME OVER" << endl;
			break;
		}
		else
		{
			myPlayer->printReport();
			myPlayer->printPlayer();
		}
	}

	if(winner)
	{
		cout<<"You have kept your people alive and 'well' for 10 years!"<< endl;
		cout<<"You are truly great!"<<endl;
		cout << setw(40) << "CONGRATULATIONS" << endl;
	}

		


	system("pause");
	return;
}

int validateIntegerInput()
{
	int input = 0;
	while(true)
	{
		cin >> input;

		if(!cin.fail())
			return input;
		else
			cout<<"Please enter only whole number values!" << endl;
		cin.clear();
		cin.ignore(numeric_limits<streamsize>::max(),'\n');
	}
}

//Getting input from user and validating
void getInput(Player* myPlayer)
{
	int nland;
	int nfood;
	int nseed;
	bool invalid = false;
	char doubleCheck;
	string inputLine;

	do{
		int foodRemaining = myPlayer->getFood();

		do{
			cout << "How many acres do you wish to buy (Negative to sell)? ";
			//input checking
			nland = validateIntegerInput();

			if (myPlayer->getFood() < (nland * myPlayer->getPriceOfLand()))
				cout << "You can't buy " << nland << " acres, you only have " << myPlayer->getFood() << " bushels!" << endl;
		} while (myPlayer->getFood() < (nland * myPlayer->getPriceOfLand()));

		foodRemaining -= nland * myPlayer->getPriceOfLand();

		do{
			cout << "How many bushels do you wish to feed your people? ";
			nfood = validateIntegerInput();

			if (nfood < 0)
			{
				cout<< "You can't feed people a negative amount of food!"<<endl;
				invalid = true;
			}
			else if (nfood > foodRemaining)
			{
				cout << "You can't use " << nfood << " bushels, you only have " << foodRemaining << " left!" << endl;
				invalid = true;
			}
			else
				invalid = false;
		} while (invalid);

		foodRemaining -= nfood;

		do{
			cout << "How many acres do you wish to plant with seed? ";
			nseed = validateIntegerInput();
			if (nseed < 0)
			{
				cout<< "You can't plant a negative amount of seeds!"<<endl;
				invalid = true;
			}
			else if (nseed > foodRemaining)
			{
				cout << "You can't plant " << nfood << " seeds, you only have " << foodRemaining << " left!" << endl;
				invalid = true;
			}
			else
				invalid = false;
		} while (invalid);

		foodRemaining -= nseed;

		cout << "You wish to buy " << nland << " acres, feed your people " << nfood << " bushels, and plant " << nseed << " seeds." << endl;
		cout << "This will leave you with " << foodRemaining << " bushels, is that correct? Enter N to retry. ";
		cin >> doubleCheck;
	} while (doubleCheck == 'N' || doubleCheck == 'n');

	myPlayer->updatePlayer(nland, nfood, nseed);


}

bool checkEndGame(Player* myPlayer)
{
	if (myPlayer->isUprising() || myPlayer->getPopulation() == 0)
	{
		cout << "Due to EXTREME missmanagement, " << myPlayer->getStarvingNumber() << " have starved!";
		if(myPlayer->getPopulation() == 0)
		{
			cout<<endl<<"What a terrible ruler; you have no people left to rule!"<<endl;
		}
		else{
			cout << " The remaining population" <<endl<< "has overthrown you and you have been declared the worst King in history!" << endl;
		}
			return true;
	}
	return false;
}