#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Read database

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do

# Filter out column name
if [[ $YEAR != "year" ]]
then

# Compare winner of each row to teams table

TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")

# If winner name not found
	if [[ -z $TEAM_ID ]]
	then

# Insert winner name into teams table
	INSERT_WINNER_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")

# If inserted into teams table, print response
		if [[ $INSERT_WINNER_RESULT == "INSERT 0 1" ]]
		then
			echo "Inserted into teams, '$WINNER'"
		fi

# Reaquire new list of winners from teams 
	TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
	fi

# Repeat for opponents (losers) as variable TEAM_IDO
TEAM_IDO=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
	if [[ -z $TEAM_IDO && $TEAM_ID ]]
	then
		INSERT_OPPONENT_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
		if [[ $INSERT_OPPONENT_RESULT == "INSERT 0 1" ]]
		then
			echo "Inserted into teams, '$OPPONENT'"
		fi
	TEAM_IDO=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
	fi

# Cycle through rows for games table, referencing teams table
GAME_ID=$($PSQL "SELECT year, round, winner_id FROM games WHERE year=$YEAR AND round='$ROUND' AND winner_id=$TEAM_ID")

# If the unique (year and round and winner's name) game is not found in the games table
	if [[ -z $GAME_ID ]]
	then

# Insert rest of data into games table
	INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $TEAM_ID, $TEAM_IDO, $WINNER_GOALS, $OPPONENT_GOALS)")

# If inserted successfully, print response	
		if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]
		then
			echo "Inserted into games, $YEAR '$ROUND'"
		fi
	fi
fi

done

