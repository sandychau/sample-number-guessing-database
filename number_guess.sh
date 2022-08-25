#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=number_guessing --tuples-only -c"

NUMBER=$(( RANDOM % 1000 + 1 ))

echo 'Enter your username:'
read USERNAME

# find user_id for the given USERNAME in db
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")

# if not exist, create the user and display a message
if [[ -z $USER_ID ]]
then
  INSERT_NEW_USER=$($PSQL "INSERT INTO users (username) VALUES ('$USERNAME')")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")
  echo "Welcome, $USERNAME! It looks like this is your first time here."
# if exist, summarize the existing games and display a message
else
  GAME_COUNT=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id=$USER_ID")
  BEST_GUESS=$($PSQL "SELECT MIN(guesses) FROM games WHERE user_id=$USER_ID")
  echo "Welcome back, $USERNAME! You have played $GAME_COUNT games, and your best game took $BEST_GUESS guesses."
fi


echo "Guess the secret number between 1 and 1000:"
read USER_NUMBER

# if not an integer, ask to input again
while [[ ! $USER_NUMBER =~ ^-?[0-9]+$ ]]
do
  echo "That is not an integer, guess again:"
  read USER_NUMBER
done

COUNTER=1

while [[ $USER_NUMBER -ne $NUMBER ]]
do
  if [[ $NUMBER -lt $USER_NUMBER ]]
  then
    echo "It's lower than that, guess again:"
    read USER_NUMBER
  elif [[ $NUMBER -gt $USER_NUMBER ]]
  then
    echo "It's higher than that, guess again:"
    read USER_NUMBER
  fi
  (( COUNTER ++ ))
done

echo "You guessed it in $COUNTER tries. The secret number was $NUMBER. Nice job!"

# save the result to the database
INSERT_GAME_RESULT=$($PSQL "INSERT INTO games (user_id, guesses) VALUES ($USER_ID, $COUNTER)")
