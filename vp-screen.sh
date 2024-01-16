#!/bin/bash
declare -i nb
declare -A card
fic_conf="$HOME/.config/vp-screeen/vp-screen.conf"
rep_conf="$HOME/.config/vp-screeen"
mkdir -p "$rep_conf"

if [[ -f "$fic_conf" ]] ; then 
    source "$fic_conf"
else
    echo "please run $0 -c"
fi
########################################################################################
funk_logo() {
echo -e '    \e[47m      \e[0m         \e[47m      \e[0m\t\e[1;34m888     888 d8b                            .d8888888'
echo -e '  \e[47m                         \e[0m\t\e[1;34m888     888 Y8P                           d88P   888'
echo -e ' \e[47m    \e[0m\e[44m \e[47m                 \e[0m\e[44m \e[47m    \e[0m\t\e[1;34m888     888                               888    888'
echo -e ' \e[47m    \e[0m\e[44m  \e[47m               \e[0m\e[44m  \e[47m    \e[0m\t\e[1;34mY88b   d88P 888 88888b.   .d88b.  888d888 Y88b   888'
echo -e '\e[47m     \e[0m\e[44m    \e[47m           \e[0m\e[44m    \e[47m     \e[0m\t\e[1;34m Y88b d88P  888 888 "88b d8P  Y8b 888P"    "Y8888888'
echo -e '\e[47m        \e[0m\e[44m  \e[47m         \e[0m\e[44m  \e[47m        \e[0m\t\e[1;34m  Y88o88P   888 888  888 88888888 888       d88T 888'
echo -e ' \e[47m                           \e[0m\t\e[1;34m   Y888P    888 888 d88P Y8b.     888      d88T  888'
echo -e '   \e[47m         \e[0m     \e[47m         \e[0m\t\e[1;34m    Y8P     888 88888P"   "Y8888  888     d88T   888'
echo -e '      \e[47m    \e[0m         \e[47m    \e[0m\t\e[1;34m      \e[37m___\e[0m               \e[1;34m888\e[0m                                      '
echo -e '       \e[47m  \e[0m           \e[47m  \e[0m\t\e[1;34m       \e[37m| _|_ / _    _.\e[0m  \e[1;34m888\e[0m  \e[1;37m  |_  o _|_  _    |_   _ _|_\e[0m  \e[1;34m|\e[0m'
echo -e '        \e[47m \e[0m           \e[47m \e[0m\t\e[1;34m      \e[37m_|_ |_  _>   (_|\e[0m  \e[1;34m888\e[0m  \e[1;37m  |_) |  |_ (/_   | | (_) |_\e[0m  \e[1;34mo\e[0m'
echo -e '\t\t\t\t\e[1;34m Iä! Shub-Niggurath\e[0m' 

}
########################################################################################
funk_list() {
    nb=1
    # thank topklean for : awk '/ connected /{f=1}/^$/{f=0}f' 
    xrand="$(xrandr --verbose |sed -E 's/^([A-Z])/\n\1/' |awk '/ connected /{f=1}/^$/{f=0}f' |sed -nE '/^[[:alpha:]]/ s/([^ ]+).*$/\1/p; /EDID:/ N;s/\n/ /;/EDID:/ N;s/\n/ /;/EDID:/ N;s/\n/ /;/EDID:/ N;s/\n/ /;/EDID:/ N;s/\n/ /;/EDID:/ N;s/\n/ /;/EDID:/ N;s/\n/ /;/EDID:/ N;s/\n/ /;/EDID:/ s/[[:space:]]//g;s/EDID://p;/\+preferred/ s/^ +([^ ]+) .*$/\1\n/p' |sed 'N;s/\n/ /;N;s/\n/ /;N;s/\n/ /')"
    for carte in /sys/class/drm/card?-* ; do
        #thank topklean for : $(< "$carte/status")
        status=$(< "$carte/status")
        if [[ "$status" = connected ]] ; then
            card["$nb,edid"]=$(edid-decode -H "$carte"/edid |sed -nE '/[^e ]/ N;s/\n//;N;s/\n//;N;s/\n//;N;s/\n//;N;s/\n//;N;s/\n//;N;s/\n//;N;s/\n//;N;s/\n//;s/ //g;s/^.*:([^:])/\1/p')
            output="$(edid-decode "$carte"/edid)"
            card["$nb,serial"]="$(echo "$output" |grep -A1 "Display Product Serial Number" |awk -F"'" '{print $2}' |sed -n '1p')"
            card["$nb,name"]="$(echo "$output" |grep -A1 "Display Product Serial Number" |awk -F"'" '{print $2}' |sed -n '2p')"
            while read screen edid size ; do
                if echo "$edid" | grep -qs "${card[$nb,edid]}" ; then
                    card["$nb,screen"]="$screen"
                    card["$nb,size"]="$size"
                fi
            done < <(echo "$xrand")
        fi
        if [[ "${card[$nb,status]}" != "$status" ]] ; then
            card["$nb,status"]="$status"
        fi
        card["$nb,carte"]="$carte"
        nb+=1
    done
    (( nb-- ))
}
declare -A card
########################################################################################
funk_status() {
    funk_list
    printf "\e[1m%-14s %-1s %-10s %-1s %-20s %-1s %-20s %-1s %-11s %-1s\n\e[0m" "|Number" "|" "Ecran" "|" "Nom" "|" "Serial" "|" "Resolution" "|"
    for (( i=1 ; i<=nb ; i+=1 )) ; do
        if [[ "${card[$i,status]}" = "connected" ]] ; then
        #echo "carte $i : ${card[$i,carte]};${card[$i,status]};${card[$i,name]:-no name};${card[$i,serial]:-no serial};${card[$i,edid]};${card[$i,screen]};${card[$i,size]}"
        
        printf "%-15s %-1s %-10s %-1s %-20s %-1s %-20s %-1s %-11s %-1s\n" "|screen n°$i" "|" "${card[$i,screen]}" "|" "${card[$i,name]:-no name}" "|" "${card[$i,serial]:-no serial}" "|" "${card[$i,size]}" "|"
        fi
    done
    unset i
}
#######################################################################################
funk_config() {
    echo " Assuming you want such setup, here are the answer you would pick
______________   ______________   ______________   ______________
|            |   |  primary   |   |            |   |            |
|    N° 3    |   |    N° 6    |   |    N° 2    |   |    N° 1    |
|   HDMI-2   |   |   eDP-1    |   |   DP-1-3   |   |   DP-1-1   |
| 1920x1200  |   | 1920x1080  |   | 1680x1050  |   | 1920x1200  |
| DELL P2421 |   |  No-name   |   |  No-Name   |   |   Viperr   |
| SN : 666   |   | No-Serial  |   | SN : 2000  |   | SN : 2001  |
|____________|   |____________|   |____________|   |____________|

            Question 1 : select your primary
                Answer : 6
            Next Questions  : 
                select order of the screens left to right : 
                Answer : 3 6 2 1
                "
    funk_status
    declare -i i
    declare -i screen
    declare -A setting
    read -p "Witch primary screen do you want ? : " screen
    if [[ $screen -eq 0  ]] ; then
        echo "Glaviouses à la moukraine" 
	    exit 2
    else
        PRIMARY_screen=${card[$screen,screen]}
        PRIMARY_size=${card[$screen,size]}
    fi
    read -p "select order of the screens (left to right | number espected) : " order
    if [[ -z "$order" ]] ; then
        echo "Glaviouses à la moukraine"
        exit 2
    fi
    ##############################construction du fichier de conf
    HEAD="##Do Not Edit This File /!\ ##"
    declare -i l=0
    for k in $order ; do
        setting[$l]="${card[$k,screen]} ${card[$k,size]} ${card[$k,edid]};"
        l+=1
    done
    unset k
    #thank topklean for : <<-
    cat > "$fic_conf" <<-EOF
	$HEAD
	PRIMARY_screen=$PRIMARY_screen
	PRIMARY_size=$PRIMARY_size
	ECRAN="$(echo ${setting[@]} | sed 's/;/\n/g')"
	EOF
}
########################################################################################
funk_restart_polybar() {
    if hash polybar ; then
        ~/.config/polybar/launch_polybar.sh
    fi
}
#######################################################################################
funk_load_default() {
    echo "$xrand"
#if ( for edid in $(echo "$xrand" | awk '{print $2}') ; do if ! grep  "$edid" ~/.config/vp-screeen/vp-screen.conf ; then exit 2 ; fi ;done ) ; then 
if ( for edid in $(echo "$ECRAN " | awk '{print $3}') ; do if ! echo "$xrand" | grep "$edid" ; then exit 2 ; fi ; done) ; then
#if ! echo "$xrand" | grep "$edid" ; then
    pos=0
    while read screen size edid ; do
        if [[ "$screen" = "$PRIMARY_screen" ]] ; then
            rand="$rand --output $screen --primary --mode $size --pos ${pos}x0"
            pos=$(( pos + ${size%x*} ))
        else
            rand="$rand --output $screen --mode $size --pos ${pos}x0"
            pos=$(( pos + ${size%x*} ))
        fi
    # thank topklean for : <<<
    done <<< "$ECRAN"
    echo "$rand"
    xrandr $rand
else
    pos="${PRIMARY_size%x*}"
    echo "$xrand"
        for (( i=1 ; i<=nb ; i+=1 )) ; do
                echo "detected ${card[$i,screen]} ${card[$i,size]}"
                if [[ "${card[$i,status]}" = connected && "${card[$i,screen]}" !=  "$PRIMARY_screen" ]] ; then
                    rand[$i]="--output ${card[$i,screen]} --mode ${card[$i,size]} --pos ${pos}x0 "
                    size="${card[$i,size]%x*}"
                    pos="$(( $pos + ${size:-0}))"
                fi
        done
        unset i
        echo "xrandr --output $PRIMARY_screen --mode $PRIMARY_size --pos 0x0 ${rand[*]}"
        xrandr --output "$PRIMARY_screen" --mode "$PRIMARY_size" --pos 0x0 ${rand[*]}
fi
unset rand
pos=0
funk_restart_polybar
}
#######################################################################################
funk_daemon() {
funk_list
funk_load_default
actif=$(cat /sys/class/drm/card?-*/status)
while true ; do

    declare -A card
    pos=${PRIMARY_size%x*}
    #inotifywait  -e close_nowrite  /sys/class/drm/card?-*/device/ #> /dev/null
    if [[ "$actif" != $(cat /sys/class/drm/card?-*/status) ]] ; then
        sleep 4
        funk_list
        funk_load_default
        funk_restart_polybar
        unset rand
        pos=0
        actif=$(cat /sys/class/drm/card?-*/status)
    fi
    sleep 1

unset card
done
}
#######################################################################################
main() {
while [[ -n "$1" ]]
	do
	case $1 in 
	-l|--list)
		funk_status
        exit
	;;
	-d|--daemon)
		funk_list
        funk_daemon
	;;
    -c|--configuration)
        funk_logo
        funk_config
    ;;
    -L|--logo)
        funk_logo
    ;;
    esac
    shift 1
done
}
##################################~Let's GOOOOOOOOOOOOOOOOOOOO~#####################################################
main "$@"
