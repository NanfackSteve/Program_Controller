#!/bin/bash

##Colors
r='\e[1;91m' && g='\e[1;92m' && y='\e[1;93m' && b='\e[1;96m' && w='\e[1;97m' && n='\e[0m'

# Exit if it isn't a command or file
if [ -z "$(command -v "$1")" ]; then
  if [ ! -e "$1" ]; then
    echo -e "\n$r[ error ] : file/program doesn't exist !!\n" && exit 1
  fi
  script="$(realpath $1)"
fi

[[ -z "$script" ]] && script="$1"
prog_name="${script##/*/}"
pid=$(pidof -sx "$prog_name")

log_dir="$HOME/.controller"
[[ ! -d "$log_dir" ]] && mkdir -p "$log_dir"
log_file="$log_dir/controller_${prog_name/'.'/'_'}.log"

if [ "$2" = "" ]; then # [ NOT USE FORCE REBOOT ]

  if [ -n "$pid" ]; then # if PID exist
    echo -e "\n($g $pid $n) - $w$prog_name$n ... $g[ Status : running ] $n\n"
    echo -e "$pid $prog_name" >"$log_file"
    exit 0 # Do nothing

  else # if PID not exist
    echo -ne "\n($r NO PID $n) - $w$prog_name$n ... $r[ Status : stopped ] \n\n$n==> starting... " && sleep 2
    "$script" 1>/dev/null &

    pid=$(pidof -sx "$prog_name")
    [[ -n "$pid" ]] && echo -e "$pid $prog_name" >"$log_file" && echo -e " $g($pid) - $g[ OK ]$n\n"

  fi

elif [ "$2" = "-r" ] || [ "$2" = "--reboot" ]; then # [ FORCE REBOOT !!! ]

  echo -ne "\n$y[ Warning ] - $r Force restarting $n$w$prog_name $y...$n" && sleep 2
  killall -9 $prog_name 2>/dev/null
  "$script" 1>/dev/null &

  pid=$(pidof -sx "$prog_name")
  [[ -n "$pid" ]] && echo -e "$pid $prog_name" >"$log_file" && echo -e " $b($pid) - $g[ OK ]$n\n"

else
  echo -e $r"\n [ Error ] - Bad script usage.$n\n$w   Usage : $0 \e[4mprogram$n [ -r|--reboot ] $n\n"
fi
