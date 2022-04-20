#!/bin/sh
ui=$(tty)
case $ui in /dev/tty*) false; esac &&
if [ "${DE+x}" = x ] || [ "${WM+x}" = x ]; then
	ui="${DE:+DE}${DE:+${WM:+/}}${WM:+WM}:      ${DE:+${WM:+$'\33[3D'}}$DE${DE:+${WM:+/}}$WM"
elif [ "${XDG_CURRENT_DESKTOP:-${DESKTOP_SESSION-}}" != '' ]; then
	ui="DE:      ${XDG_CURRENT_DESKTOP:-}${XDG_CURRENT_DESKTOP:+${DESKTOP_SESSION:+, }}${DESKTOP_SESSION:-}"
elif [[ -r ~/.xinitrc || -r ~/.xsession ]]; then
	uiexec=
	for i in $(sed -ne 's/^exec //p' ~/.xinitrc ~/.xsession 2>/dev/null); do
		case $(pidof -- "$uiexec") in ?*) uiexec=$uiexec${i##*/}; esac
	done
	[ "${uiexec% }" != '' ] && ui="WM:      ${uiexec% }"
fi || ui="TTY:     ${ui#/dev/}${SSH_TTY:+, ssh}"

# [[ $os ]] || os=$(sed -ne 's/PRETTY_NAME=//p' "$PREFIX/etc/os-release" || echo "$MACHTYPE"); os=${os#[\'\"]}; os=${os%[\'\"]}
case ${os+x} in '')
. "$PREFIX/etc/os-release"
os=${PRETTY_NAME:-${NAME:-$MACHTYPE}}
esac

IFS=$(printf \\33)

c=4 # def. color blue (Arch, BTW)

case ${os%" "[Ll][Ii][Nn][Uu][Xx]} in

[Aa]rch)a=\
'     .    
    / \   
   / _ \  
  / / \ \ 
 /`     `\'
;;

[Aa]rco*)a=\
'     .    
    / \   
   / . \  
  / / _ \ 
 /`     `\'
;;

[Aa]rtix)a=\
"     .    
    / \\   
   /.  \\  
  /   * \\ 
 /   '   \\"
c=6;;

[Aa]lpine)a=\
'
   /\
  /  \'$IFS' /\'$IFS'
 /'$IFS'◁'$IFS'   \'$IFS'  
';
c='4 8 4 8 4 8 4 4 8';l=12;;

[Aa]ndroid)a=\
'
 ╲_____╱ 
 ╱ . . ╲ 
▕       ▏
 ▔▔▔▔▔▔▔ '
c=2;l=9;;
 
KISS|[Kk]iss)a=\
'
 +----+
 | |/ |
 | |\ |
 +----+'
c=1;l=8;;
 
[Mm]anjaro*)a=\
'
 █████ ██
 ██ ▄▄ ██
 ██ ██ ██
 ██ ██ ██'
c=2;l=10;;

[Dd]ebian)a=\
'  ,--. 
 /  _ \
|  (__/
 \     
  `-.  '
c=1;l=9;;

# Space Invaders
*)a=\
'░░▀▄░░░▄▀░░
░▄█▀███▀█▄░
█▀███████▀█
█░█▀▀▀▀▀█░█
░░░▀▀░▀▀░░░'
c=$(( ${RANDOM:-$(\dd if=/dev/random | tr -dc 0-9 | head -c 1)} % 7 + 1 ));l=12;;

esac



# printf '\33[3'"$c"'m%s\33[m\n\33[5A' "$a"
set -f
for i in $a; do
	printf "\\33[3${c%%" "*}m%s" "${i}"
	c=${c#*" "} # note: last val wont be auto removed
done
printf '\33[m\n\33[5A'

p=$(printf '\33[3%im%s\33[m@%s \33[3%im%s\33[m'  "$(( ${EUID:-$(id -u)} == 0 ? 1 : 3 ))" "${USER:-$(id -un)}" "${HOSTNAME:-$(hostname)}" "$c" "${PWD:-$(pwd)}") # prompt
b=;for i in /sys/class/power_supply/{{BAT,axp288_fuel_gauge,CMB}*,battery}; do [ -r "$i"/capacity ] && b=$b${b:+, }$(cat "$i"/capacity)"% "$(cat "$i"/status); done # 1 line detect battery level
printf "\\33[${l:-11}C%s\\n" \
	"$p" \
	"OS:      $os" \
	"KERNEL:  $(uname -r)" \
	"${b:+BATTERY: }${b:-SHELL:   $(basename -- ${SHELL:-$0})}" \
	"$ui" \
;
