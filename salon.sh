#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"
# echo $($PSQL "TRUNCATE appointments, customers")

echo -e "\n~~~~~ MY SALON ~~~~~"

MAIN_MENU (){
  echo -e "\nWelcome to My Salon, how can I help you?\n"

  APPOINTMENT_MENU
}

APPOINTMENT_MENU () {
  if [[ $1 ]] 
  then
    echo -e "\n$1"
  fi

  # get available services
  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services")

  # if no services available
  if [[ -z $AVAILABLE_SERVICES ]]
  then
    # print no services and end program
    echo -e "\nNo services available"
  else
    # display available services 
    echo -e "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
    do
      echo "$SERVICE_ID) $SERVICE_NAME"
    done

    read SERVICE_ID_SELECTED

    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
      APPOINTMENT_MENU "I could not find that service. What would you like today?"
    else
      # get service 
      SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

      if [[ -z $SERVICE_NAME ]] 
      then
        APPOINTMENT_MENU "I could not find that service. What would you like today?"
      else
        # ask for phone number
        echo -e "\nWhat's your phone number?"
        read CUSTOMER_PHONE

        # get customer id
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'") 
        
        # if not customer id
        if [[ -z $CUSTOMER_ID ]]
        then
          # ask for name
          echo -e "\nI don't have a record for that phone number, what's your name?"
          read CUSTOMER_NAME

          # insert customer 
          INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")

          CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'") 
        fi

        #get customer name
        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID")


        # ask for time
        echo -e "\nWhat time would you like your color,$CUSTOMER_NAME?"
        read SERVICE_TIME
        
        # save appointmen
        INSERT_APPOINTMENT_RESUTL=$($PSQL "INSERT INTO appointments (CUSTOMER_ID, SERVICE_ID, TIME) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
        
        # show message
        echo -e "\nI have put you down for a$SERVICE_NAME at $SERVICE_TIME,$CUSTOMER_NAME."
      fi
    fi 
  fi
}
