#!/bin/bash

##Colors
rd='\e[1;91m' ; g='\e[1;92m' ; y='\e[1;93m' ; b='\e[1;96m' ; w='\e[1;97m' ; n='\e[0m'

#if [ ! -e "$1" ]; then echo -e "\n$rd [ error ] : file doesn't exist !!\n" ; exit 1; fi 

full_path="$(realpath $1)"
path="${full_path%/*}"
prog_name="$(basename $full_path)"
log="$path"/'process.log'
script="$path"/"$prog_name"
echo $prog_name && exit

# Si $log n'existe pas et que le processus existe on le tue
if [ ! -e "$log" ]; then
  if [ -n "$(ps -C $prog_name -o pid=)" ]; then kill -9 $(ps -C $prog_name -o pid=) ; fi
  "$script" 1> /dev/null &
  sleep 2
  exit 0
fi

# Si $log existe mais PID vide, on tue le processus s'il existe
pid=$(cut -d' ' -f1 "$log")
if [ -z "$pid" ]; then 
  if [ -n "$(ps -C $prog_name -o pid=)" ]; then kill $(ps -C ${script##/*/} -o pid=) ; fi
  "$script" 1> /dev/null &  
  sleep 2
  exit 0
fi

# Si $log existe et contient un PID
if [ "$2" = "" ]; then
  
  if [ -n "$(ps -q "$pid" -o pid=)" ]; then # Test si le PID existe
  
    if [ "$(ps -q "$pid" -o comm=)" = "$prog_name" ]; then # Test si le nom correspond	
      echo -e "\n($g$pid$n) - $w$prog_name$n ... $g[ Status : running ] \n"
      exit 0 # Ne rien faire
    fi
  
    ## Relancer le script
    echo -ne "\n($y$pid$n) - $w$prog_name$n - $rdPID don't match$n ... $rd[ Status : stopped ] \n$y==> rebooting... \n" ; sleep 2  
    
    "$script" 1> /dev/null & 
    echo -e " $g[ OK ]$n\n"
  
  else
    
    ## Relancer le script 
    echo -ne "\n($y$pid$n) - $w$prog_name$n - $y PID not exist$n ... $rd[ Status : stopped ] \n\n$n==> rebooting... " ; sleep 2  
    
    "$script" 1> /dev/null &
    echo -e " $g[ OK ]$n\n"
  
  fi

elif [ "$2" = "-r" ] || [ "$2" = "--reboot" ];then

  ## Redemarrage FORCE !!!
  echo -ne "\n$y[ Warning ] - Force rebooting ...$n" ; sleep 2
  
  kill -9 $pid 2> /dev/null
  "$script"  1> /dev/null &
  echo -e " $g[ OK ]$n\n"

else
  echo -e $rd"\n [ Error ] - Bad script usage.$n\n$w   Usage : $0 [ -r|--reboot ] \n"
fi
