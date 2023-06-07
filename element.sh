#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# Check if user provides element
if [[ -z $1 ]]
then

  # Ask user to provide element if none provided
  echo "Please provide an element as an argument."
else

  # Query for atomic number
  # Check if the argument is integer or not
  re='^[0-9]+$'
  if [[ $1 =~ $re ]]
  then

    # Check if atomic number exist in the database
    ATOMIC_NUMBER_QUERY_RESULT=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number = $1;")
  else

    # Look for the atomic number of given name or symbol
    ATOMIC_NUMBER_QUERY_RESULT=$($PSQL "SELECT atomic_number FROM elements WHERE symbol = '$1' OR name = '$1';")
  fi

  if [[ ! -z $ATOMIC_NUMBER_QUERY_RESULT ]]
    then
      
      # Query element info
      INFO_QUERY_RESULT=$($PSQL "
      SELECT e.atomic_number, 
      e.symbol, 
      e.name, 
      p.atomic_mass, 
      p.melting_point_celsius, 
      p.boiling_point_celsius, 
      t.type
      FROM elements e 
      INNER JOIN properties p 
      ON p.atomic_number = e.atomic_number
      INNER JOIN types t
      ON t.type_id = p.type_id
      WHERE e.atomic_number = $ATOMIC_NUMBER_QUERY_RESULT;")
      echo $INFO_QUERY_RESULT | while IFS='|' read ATOMIC_NUM SYMBOL NAME ATOMIC_MASS MELTING_PT BOILING_PT TYPE
      do

        # Output message with information of the element
        echo "The element with atomic number $ATOMIC_NUM is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_PT celsius and a boiling point of $BOILING_PT celsius."
      done
    else
    
      # Output message if element not found
      echo "I could not find that element in the database."
  fi
fi
