#!/bin/bash

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

function ctrl_c(){
  echo -e "\n\n${redColour} [!] Saliendo...${endColour}\n"
  tput cnorm; exit 1
}

# Ctrl+C
trap ctrl_c INT

function helpPanel(){
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} Uso:${endColour}${purpleColour} $0${endColour}\n"
  echo -e "\t${blueColour}-m)${endColour}${grayColour} Dinero con el que se desea jugar${endColour}"
  echo -e "\t${blueColour}-t)${endColour}${grayColour} Técnica a utilizar${endColour}${purpleColour} (${endColour}${yellowColour}martingala${endColour}${blueColour}/${endColour}${yellowColour}inverseLabouchere${endColour}${purpleColour})${endColour}\n"
  exit 1
}

function martingala(){
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} Dinero actual: ${endColour}${yellowColour}$money€${endColour}"
  echo -ne "${yellowColour}[+]${endColour}${grayColour} ¿Cuánto dinero tienes pensado apostar? -> ${endColour}" && read initial_bet
  echo -ne "${yellowColour}[+]${endColour}${grayColour} ¿A qué deseas apostar continuamente (par/impar)? -> ${endColour}" && read par_impar
  
  if [ ! "$initial_bet" ] || [ ! "$par_impar" ]; then
     echo -e "\n${redColour}[!] Tienes que completar los dos campos${endColour}\n"
     exit 1
  fi

  if [ "$initial_bet" -eq 0 ] || [ "$initial_bet" -lt 0 ]; then
    echo -e "\n${redColour}[!] Cantidad insuficiente para apostar${endColour}\n"
    exit 1
  fi

  if [ "$par_impar" != "par" ] && [ "$par_impar" != "impar" ]; then
    echo -e "\n${redColour}[!] La apuesta solo puede ser a 'par' o a 'impar'${endColour}\n"
    exit 1
  fi

  echo -e "\n${yellowColour}[+]${endColour}${grayColour} Vamos a jugar con una cantidad inicial de ${endColour}${yellowColour}$initial_bet€${endColour}${grayColour} a${endColour}${yellowColour} $par_impar${endColour}"

  backup_bet=$initial_bet
  play_counter=1
  jugadas_malas=""
  max_money="$money"

  tput civis # Ocultar el cursor
  while true; do
    money=$(($money-$initial_bet))
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Acabas de apostar${endColour}${yellowColour} $initial_bet€${endColour}${grayColour} y tienes${endColour}${yellowColour} $money€${endColour}"
    random_number="$(($RANDOM % 37))"
    echo -e "${yellowColour}[+]${endColour}${grayColour} Ha salido el número ${endColour}${blueColour}$random_number${endColour}"

    if [ "$par_impar" == "par" ]; then
      # Toda esta definición es para cuando apostamos por números pares
      if [ "$(($random_number % 2))" -eq 0 ]; then
        if [ "$random_number" -eq 0 ]; then
          echo -e "${redColour}[!] Ha salido el 0, por tanto perdemos${endColour}"
          initial_bet=$(($initial_bet*2))
          jugadas_malas+="$random_number "
          echo -e "${yellowColour}[+]${endColour}${grayColour} Ahora mismo te quedas en${endColour}${yellowColour} $money€${endColour}"
        else
          echo -e "${greenColour}[+] El número que ha salido es par, ¡Ganas!${endColour}"
          reward=$(($initial_bet*2))
          echo -e "${yellowColour}[+]${endColour}${grayColour} Ganas un total de ${endColour}${yellowColour}$reward€${endColour}"
          money=$(($money+$reward))
          echo -e "${yellowColour}[+]${endColour}${grayColour} Tienes ${endColour}${yellowColour}$money€${endColour}"
          initial_bet=$backup_bet
          jugadas_malas=""
          max_money=$money
        fi
      else
        echo -e "${redColour}[!] El número que ha salido es impar, ¡Pierdes!${endColour}"
        initial_bet=$(($initial_bet*2))
        jugadas_malas+="$random_number "
        echo -e "${yellowColour}[+]${endColour}${grayColour} Ahora mismo te quedas en${endColour}${yellowColour} $money€${endColour}"
      fi
    else
      # Toda esta definición es para cuando apostamos por números impares
      if [ "$(($random_number % 2))" -eq 1 ]; then
        echo -e "${greenColour}[+] El número que ha salido es impar, ¡Ganas!${endColour}"
        reward=$(($initial_bet*2))
        echo -e "${yellowColour}[+]${endColour}${grayColour} Ganas un total de ${endColour}${yellowColour}$reward€${endColour}"
        money=$(($money+$reward))
        echo -e "${yellowColour}[+]${endColour}${grayColour} Tienes ${endColour}${yellowColour}$money€${endColour}"
        initial_bet=$backup_bet
        jugadas_malas=""
        max_money=$money
      else
        if [ "$random_number" -eq 0 ]; then
          echo -e "${redColour}[!] Ha salido el 0, por tanto perdemos${endColour}"
          initial_bet=$(($initial_bet*2))
          jugadas_malas+="$random_number "
          echo -e "${yellowColour}[+]${endColour}${grayColour} Ahora mismo te quedas en${endColour}${yellowColour} $money€${endColour}"
        else
           echo -e "${redColour}[!] El número que ha salido es par, ¡Pierdes!${endColour}"
           initial_bet=$(($initial_bet*2))
           jugadas_malas+="$random_number "
           echo -e "${yellowColour}[+]${endColour}${grayColour} Ahora mismo te quedas en${endColour}${yellowColour} $money€${endColour}"
        fi
      fi
    fi
    if [ "$money" -le 0 ]; then
      echo -e "\n\n\n\n${redColour}[+] Te has quedado sin dinero${endColour}"
      echo -e "${yellowColour}[+]${endColour}${grayColour} Dinero máximo que has tenido en tu cuenta:${endColour}${yellowColour} $max_money€${endColour}"
      echo -e "${yellowColour}[+]${endColour}${grayColour} Ha habido un total de ${endColour}${yellowColour}$play_counter${endColour}${grayColour} jugadas${endColour}"

      echo -e "\n${yellowColour}[+]${endColour}${grayColour} A continuación se van a representar las malas jugadas consecutivas que han salido:${endColour}"
      echo -e "\n${blueColour}[ $jugadas_malas]${endColour}\n"
      tput cnorm; exit 0 
    fi

    let play_counter+=1
  done
  tput cnorm # Recuperamos el cursor
}

function inverseLabouchere(){
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} Dinero actual: ${endColour}${yellowColour}$money€${endColour}"
  echo -ne "${yellowColour}[+]${endColour}${grayColour} ¿A qué deseas apostar continuamente (par/impar)? -> ${endColour}" && read par_impar 

  if [ ! "$par_impar" ]; then
     echo -e "\n${redColour}[!] Tienes que completar el campo${endColour}\n"
     exit 1
  fi
  
  if [ "$par_impar" != "par" ] && [ "$par_impar" != "impar" ]; then
    echo -e "\n${redColour}[!] La apuesta solo puede ser a 'par' o a 'impar'${endColour}\n"
    exit 1
  fi

  declare -a my_sequence=(1 2 3 4)
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} Comenzamos con la secuencia${endColour}${greenColour} [${my_sequence[@]}]${endColour}"
  bet=$((${my_sequence[0]} + ${my_sequence[-1]}))

  play_counter=1
  max_money=$money
  bet_to_renew=$(($money+50)) # Dinero el cual una vez alcanzado hará que renovemos nuestra secuencia a [1 2 3 4]
  
  echo -e "${yellowColour}[+]${endColour}${grayColour} El tope a renovar la secuencia está establecido por encima de los${endColour}${yellowColour} $bet_to_renew€${endColour}"

  tput civis
  while true; do
    money=$(($money - $bet))
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Acabas de apostar${endColour} ${yellowColour}$bet€${endColour}${grayColour} y tienes${endColour}${yellowColour} $money€${endColour}"
    random_number=$(($RANDOM % 37))
    echo -e "${yellowColour}[+]${endColour}${grayColour} Ha salido el número ${endColour}${blueColour}$random_number${endColour}"
    
    if [ "$par_impar" == "par" ]; then
      # Toda esta definición es para cuando apostamos por números pares
      if [ "$(($random_number % 2))" -eq 0 ]; then
        if [ "$random_number" -eq 0 ]; then
          echo -e "${redColour}[!] Ha salido el 0, por tanto perdemos${endColour}"
          echo -e "${yellowColour}[+]${endColour}${grayColour} Ahora mismo te quedas en${endColour}${yellowColour} $money€${endColour}"
          if [ "$money" -lt $(($bet_to_renew-100)) ];then
            echo -e "${yellowColour}[+]${endColour}${grayColour} Hemos llegado a un mínimo crítico, se procede a reajustar el tope${endColour}"
            bet_to_renew=$(($bet_to_renew - 50))
            echo -e "${yellowColour}[+]${endColour}${grayColour} El tope ha sido renovado a${endColour}${yellowColour} $bet_to_renew€${endColour}"
            my_sequence=(1 2 3 4)
            echo -e "${yellowColour}[+]${endColour}${grayColour} Nuestra nueva secuencia es${endColour} ${greenColour}[${my_sequence[@]}]${endColour}"
            if [ "${#my_sequence[@]}" -gt 1 ]; then
              bet=$((${my_sequence[0]} + ${my_sequence[-1]}))
            fi
          else
            unset my_sequence[0]
            unset my_sequence[-1] 2>/dev/null
            my_sequence=(${my_sequence[@]})

            echo -e "${yellowColour}[+]${endColour}${grayColour} La secuencia se nos queda de la siguiente forma${endColour} ${greenColour}[${my_sequence[@]}]${endColour}"
            if [ "${#my_sequence[@]}" -gt 1 ]; then
              bet=$((${my_sequence[0]} + ${my_sequence[-1]}))
            elif [ "${#my_sequence[@]}" -eq 1 ]; then
              bet=${my_sequence[0]}
            else
              echo -e "${redColour}[!] Hemos perdido nuestra secuencia${endColour}"
              my_sequence=(1 2 3 4)
              echo -e "${yellowColour}[+]${endColour}${grayColour} Restablecemos la secuencia a${endColour}${greenColour} [${my_sequence[@]}]${endColour}"
              bet=$((${my_sequence[0]} + ${my_sequence[-1]}))
            fi
          fi
        else
          echo -e "${greenColour}[+] El número que ha salido es par, ¡Ganas!${endColour}"
          reward=$(($bet*2))
          echo -e "${yellowColour}[+]${endColour}${grayColour} Ganas un total de ${endColour}${yellowColour}$reward€${endColour}"
          let money+=$reward
          echo -e "${yellowColour}[+]${endColour}${grayColour} Tienes ${endColour}${yellowColour}$money€${endColour}"

          if [ "$money" -gt $bet_to_renew ]; then
            echo -e "${yellowColour}[+]${endColour}${grayColour} Nuestro dinero ha superado el tope de${endColour}${yellowColour} $bet_to_renew€${endColour}${grayColour} establecidos para renovar nuestra secuencia${endColour}"
            let bet_to_renew+=50
            echo -e "${yellowColour}[+]${endColour}${grayColour} El tope se ha establecido en${endColour}${yellowColour} $bet_to_renew€${endColour}"
            my_sequence=(1 2 3 4)
            bet=$((${my_sequence[0]} + ${my_sequence[-1]}))
            echo -e "${yellowColour}[+]${endColour}${grayColour} La secuencia ha sido restablecida a${endColour}${greenColour} [${my_sequence[@]}]${endColour}"
            if [ "$money" -gt "$max_money" ]; then
              max_money=$money
            fi
          else
            my_sequence+=($bet)
            my_sequence=(${my_sequence[@]})

            echo -e "${yellowColour}[+]${endColour}${grayColour} Nuestra nueva secuencia es${endColour} ${greenColour}[${my_sequence[@]}]${endColour}"
            if [ "${#my_sequence[@]}" -gt 1 ]; then
              bet=$((${my_sequence[0]} + ${my_sequence[-1]}))
            fi
            if [ "$money" -gt "$max_money" ]; then
              max_money=$money
            fi
          fi
        fi
      else
        echo -e "${redColour}[!] El número que ha salido es impar, ¡Pierdes!${endColour}"
        echo -e "${yellowColour}[+]${endColour}${grayColour} Ahora mismo te quedas en${endColour}${yellowColour} $money€${endColour}"
        if [ "$money" -lt $(($bet_to_renew-100)) ];then
          echo -e "${yellowColour}[+]${endColour}${grayColour} Hemos llegado a un mínimo crítico, se procede a reajustar el tope${endColour}"
          bet_to_renew=$(($bet_to_renew - 50))
          echo -e "${yellowColour}[+]${endColour}${grayColour} El tope ha sido renovado a${endColour}${yellowColour} $bet_to_renew€${endColour}"
          my_sequence=(1 2 3 4)
          echo -e "${yellowColour}[+]${endColour}${grayColour} Nuestra nueva secuencia es${endColour} ${greenColour}[${my_sequence[@]}]${endColour}"
          if [ "${#my_sequence[@]}" -gt 1 ]; then
            bet=$((${my_sequence[0]} + ${my_sequence[-1]}))
          fi
        else
          unset my_sequence[0]
          unset my_sequence[-1] 2>/dev/null
          my_sequence=(${my_sequence[@]})

          echo -e "${yellowColour}[+]${endColour}${grayColour} La secuencia se nos queda de la siguiente forma${endColour} ${greenColour}[${my_sequence[@]}]${endColour}"
          if [ "${#my_sequence[@]}" -gt 1 ]; then
            bet=$((${my_sequence[0]} + ${my_sequence[-1]}))
          elif [ "${#my_sequence[@]}" -eq 1 ]; then
            bet=${my_sequence[0]}
          else
            echo -e "${redColour}[!] Hemos perdido nuestra secuencia${endColour}"
            my_sequence=(1 2 3 4)
            echo -e "${yellowColour}[+]${endColour}${grayColour} Restablecemos la secuencia a${endColour}${greenColour} [${my_sequence[@]}]${endColour}"
            bet=$((${my_sequence[0]} + ${my_sequence[-1]}))
          fi
        fi
      fi
    else
      # Toda esta definición es para cuando apostamos por números impares
      if [ "$(($random_number % 2))" -eq 1 ]; then
          echo -e "${greenColour}[+] El número que ha salido es impar, ¡Ganas!${endColour}"
          reward=$(($bet*2))
          echo -e "${yellowColour}[+]${endColour}${grayColour} Ganas un total de ${endColour}${yellowColour}$reward€${endColour}"
          let money+=$reward
          echo -e "${yellowColour}[+]${endColour}${grayColour} Tienes ${endColour}${yellowColour}$money€${endColour}"

          if [ "$money" -gt $bet_to_renew ]; then
            echo -e "${yellowColour}[+]${endColour}${grayColour} Nuestro dinero ha superado el tope de${endColour}${yellowColour} $bet_to_renew€${endColour}${grayColour} establecidos para renovar nuestra secuencia${endColour}"
            let bet_to_renew+=50
            echo -e "${yellowColour}[+]${endColour}${grayColour} El tope se ha establecido en${endColour}${yellowColour} $bet_to_renew€${endColour}"
            my_sequence=(1 2 3 4)
            bet=$((${my_sequence[0]} + ${my_sequence[-1]}))
            echo -e "${yellowColour}[+]${endColour}${grayColour} La secuencia ha sido restablecida a${endColour}${greenColour} [${my_sequence[@]}]${endColour}"
            if [ "$money" -gt "$max_money" ]; then
              max_money=$money
            fi
          else
            my_sequence+=($bet)
            my_sequence=(${my_sequence[@]})

            echo -e "${yellowColour}[+]${endColour}${grayColour} Nuestra nueva secuencia es${endColour} ${greenColour}[${my_sequence[@]}]${endColour}"
            if [ "${#my_sequence[@]}" -gt 1 ]; then
              bet=$((${my_sequence[0]} + ${my_sequence[-1]}))
            fi
            if [ "$money" -gt "$max_money" ]; then
              max_money=$money
            fi
          fi
      else
        if [ "$random_number" -eq 0 ]; then
          echo -e "${redColour}[!] Ha salido el 0, por tanto perdemos${endColour}"
          echo -e "${yellowColour}[+]${endColour}${grayColour} Ahora mismo te quedas en${endColour}${yellowColour} $money€${endColour}"
          if [ "$money" -lt $(($bet_to_renew-100)) ];then
            echo -e "${yellowColour}[+]${endColour}${grayColour} Hemos llegado a un mínimo crítico, se procede a reajustar el tope${endColour}"
            bet_to_renew=$(($bet_to_renew - 50))
            echo -e "${yellowColour}[+]${endColour}${grayColour} El tope ha sido renovado a${endColour}${yellowColour} $bet_to_renew€${endColour}"
            my_sequence=(1 2 3 4)
            echo -e "${yellowColour}[+]${endColour}${grayColour} Nuestra nueva secuencia es${endColour} ${greenColour}[${my_sequence[@]}]${endColour}"
            if [ "${#my_sequence[@]}" -gt 1 ]; then
              bet=$((${my_sequence[0]} + ${my_sequence[-1]}))
            fi
          else
            unset my_sequence[0]
            unset my_sequence[-1] 2>/dev/null
            my_sequence=(${my_sequence[@]})

            echo -e "${yellowColour}[+]${endColour}${grayColour} La secuencia se nos queda de la siguiente forma${endColour} ${greenColour}[${my_sequence[@]}]${endColour}"
            if [ "${#my_sequence[@]}" -gt 1 ]; then
              bet=$((${my_sequence[0]} + ${my_sequence[-1]}))
            elif [ "${#my_sequence[@]}" -eq 1 ]; then
              bet=${my_sequence[0]}
            else
              echo -e "${redColour}[!] Hemos perdido nuestra secuencia${endColour}"
              my_sequence=(1 2 3 4)
              echo -e "${yellowColour}[+]${endColour}${grayColour} Restablecemos la secuencia a${endColour}${greenColour} [${my_sequence[@]}]${endColour}"
              bet=$((${my_sequence[0]} + ${my_sequence[-1]}))
            fi
          fi
        else
          echo -e "${redColour}[!] El número que ha salido es par, ¡Pierdes!${endColour}"
          echo -e "${yellowColour}[+]${endColour}${grayColour} Ahora mismo te quedas en${endColour}${yellowColour} $money€${endColour}"
          if [ "$money" -lt $(($bet_to_renew-100)) ];then
            echo -e "${yellowColour}[+]${endColour}${grayColour} Hemos llegado a un mínimo crítico, se procede a reajustar el tope${endColour}"
            bet_to_renew=$(($bet_to_renew - 50))
            echo -e "${yellowColour}[+]${endColour}${grayColour} El tope ha sido renovado a${endColour}${yellowColour} $bet_to_renew€${endColour}"
            my_sequence=(1 2 3 4)
            echo -e "${yellowColour}[+]${endColour}${grayColour} Nuestra nueva secuencia es${endColour} ${greenColour}[${my_sequence[@]}]${endColour}"
            if [ "${#my_sequence[@]}" -gt 1 ]; then
              bet=$((${my_sequence[0]} + ${my_sequence[-1]}))
            fi
          else
            unset my_sequence[0]
            unset my_sequence[-1] 2>/dev/null
            my_sequence=(${my_sequence[@]})

            echo -e "${yellowColour}[+]${endColour}${grayColour} La secuencia se nos queda de la siguiente forma${endColour} ${greenColour}[${my_sequence[@]}]${endColour}"
            if [ "${#my_sequence[@]}" -gt 1 ]; then
              bet=$((${my_sequence[0]} + ${my_sequence[-1]}))
            elif [ "${#my_sequence[@]}" -eq 1 ]; then
              bet=${my_sequence[0]}
            else
              echo -e "${redColour}[!] Hemos perdido nuestra secuencia${endColour}"
              my_sequence=(1 2 3 4)
              echo -e "${yellowColour}[+]${endColour}${grayColour} Restablecemos la secuencia a${endColour}${greenColour} [${my_sequence[@]}]${endColour}"
              bet=$((${my_sequence[0]} + ${my_sequence[-1]}))
            fi
          fi
        fi
      fi
    fi
    if [ "$money" -le 0 ]; then
      echo -e "\n\n\n\n${redColour}[+] Te has quedado sin dinero${endColour}"
      echo -e "${yellowColour}[+]${endColour}${grayColour} Dinero máximo que has tenido en tu cuenta:${endColour}${yellowColour} $max_money€${endColour}"
      echo -e "${yellowColour}[+]${endColour}${grayColour} Ha habido un total de ${endColour}${yellowColour}$play_counter${endColour}${grayColour} jugadas${endColour}\n"
      tput cnorm; exit 0 
    fi

    let play_counter+=1
  done
  tput cnorm
}

while getopts "m:t:h" arg; do
  case $arg in
    m) money="$OPTARG";;
    t) technique="$OPTARG";;
    h) helpPanel;;
  esac
done

if [ "$money" ] && [ "$technique" ]; then
  if [ "$money" -eq 0 ] || [ "$money" -lt 0 ]; then
    echo -e "\n${redColour}[!] Dinero insuficiente para jugar${endColour}\n"
    helpPanel
  fi
  if [ "$technique" == "martingala" ]; then
    martingala
  elif [ "$technique" == "inverseLabouchere" ]; then
    inverseLabouchere
  else
    echo -e "\n${redColour}[!] La técnica introducida no existe${endColour}"
    helpPanel
  fi
else
  helpPanel
fi
