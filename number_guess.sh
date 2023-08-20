#!/bin/bash
PSQL="psql -X -U freecodecamp -d number_guess -t -A -c "
# create stdout stderr text output file
touch null.txt

WELCOME() {
  echo "Enter your username:"
  read USERNAME_INPUT
  USERNAME=$($PSQL "SELECT username FROM user_info WHERE username='$USERNAME_INPUT';")
  if [[ -z $USERNAME ]]
  then
    echo "Welcome, $USERNAME_INPUT! It looks like this is your first time here."
    echo $($PSQL "INSERT INTO user_info(username) VALUES('$USERNAME_INPUT');") >> null.txt 2>&1
    NEW=true
    GAMES_PLAYED=0
  else
    GAMES_PLAYED=$($PSQL "SELECT games_played FROM user_info WHERE username='$USERNAME';")
    BEST_GAME=$($PSQL "SELECT best_game FROM user_info WHERE username='$USERNAME';")
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
    NEW=false
  fi
}

GUESS_NUMBER() {
  SECRET=$(( $RANDOM % 1000 + 1 ))
  echo "Guess the secret number between 1 and 1000:"
  LOOP_FLAG=true
  COUNT=0
  while $LOOP_FLAG
  do
    ((COUNT++))
    read GUESS_INPUT
    if [[ $GUESS_INPUT =~ ^[0-9]+$ ]]
    then
      if [[ $SECRET -lt $GUESS_INPUT ]]; then
        echo "It's lower than that, guess again:"
      elif [[ $SECRET -gt $GUESS_INPUT ]]; then
        echo "It's higher than that, guess again:"
      else
        echo "You guessed it in $COUNT tries. The secret number was $SECRET. Nice job!"
        LOOP_FLAG=false
      fi
    else
      echo "That is not an integer, guess again:"
    fi
  done
  SAVE_DATA $COUNT
}

SAVE_DATA() {
  if [[ $NEW ]]
  then
    echo $($PSQL "UPDATE user_info SET games_played=1 WHERE username='$USERNAME_INPUT';") >> null.txt 2>&1
    echo $($PSQL "UPDATE user_info SET best_game=$1 WHERE username='$USERNAME_INPUT';") >> null.txt 2>&1
  else
    ((GAMES_PLAYED++))
    BEST_GAME=$(( $BEST_GAME <= $COUT ?  $BEST_GAME : $COUNT ))
    echo $($PSQL "UPDATE user_info SET games_played=$GAMES_PLAYED WHERE username='$USERNAME_INPUT';") >> null.txt 2>&1
    echo $($PSQL "UPDATE user_info SET best_game=$BEST_GAME WHERE username='$USERNAME_INPUT';") >> null.txt 2>&1
  fi
}

WELCOME
GUESS_NUMBER

# remove stdout stderr text output file
rm null.txt