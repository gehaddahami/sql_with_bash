#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
# Ensuring the existing tables are empty
echo $($PSQL "TRUNCATE teams, games RESTART IDENTITY CASCADE")

# Appending the data into the script (while avoiding the header column)
cat games.csv | sed 1d | while IFS="," read year round winner opponent winner_goals opponent_goals

# Insert the team name into the teams table 
do 
  for TEAM in "$winner" "$opponent"
  do 
    # Check if the name already exists 
    team_id=$($PSQL "SELECT team_id FROM teams WHERE name='$TEAM'")
    if [[ -z $team_id ]] 
    then 
      # Insert the team into the teams (name) table  
      insert_team=$($PSQL "INSERT INTO teams(name) VALUES ('$TEAM')") 

      # If the name is successfully inserted 
      if [[ $insert_team == "INSERT 0 1" ]]
      then 
        echo "$winner inserted into teams table" 
      fi 
    fi 
  done
done 


# Read the CSV file again, "it needs to be done every time data is inserted into a table even if it is the same CSV file"
cat games.csv | sed 1d | while IFS="," read year round winner opponent winner_goals opponent_goals

# Insert data into the games table 
do 
  # Query the winner and opponents IDs from the teams table
  winner_id=$($PSQL "SELECT team_id FROM teams WHERE name='$winner'")
  opponent_id=$($PSQL "SELECT team_id FROM teams WHERE name='$opponent'")
  
  # Ensuring that both IDs are obtained and no empty values are existing 
  if [[ -n $winner_id && -n $opponent_id ]]  
  then 
    # Insert the data into the games table 
    insert_data=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) 
                          VALUES($year, '$round', $winner_id, $opponent_id, $winner_goals, $opponent_goals)")
    
    # If successfully inserted:                      
    if [[ $insert_data == "INSERT 0 1" ]]
        then 
          echo "Game: $winner vs $opponent in $year inserted into games table" 
    fi 
  fi
done 
