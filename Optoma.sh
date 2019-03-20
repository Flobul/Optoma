#!/bin/bash

# Use echo -e "$(~/Applications/Optoma/Optoma.sh)" to print all output at once

usage () {
	echo "Usage: $(basename $0) command [parameter] [ip-address [port]]"
}

help () {
	usage
	echo
	echo "Command  Parameter"
	echo "FanSpeed                                       Get current Fan Speed"
	echo "Systemp                                        Get current System temperature"
	echo "Filterusage                                    Get current Filter Usage in hours"
	echo "PowerMode                                      Get current Power Mode (Standby)"
	echo "CurrentWatt                                    Get current Consomation in Watt"
	echo "Information                                    Get current information of projector"
	echo "OtherInformation                               Get other information of projector"
	echo "Power          On|Off|Status                   Turn projector on or off, or get power status"
	echo "Brightness     Bright|Eco|Eco+|Dynamic|DynamicBlack Off|
               DynamicBlack 1|DynamicBlack 2|DynamicBlack 3
                                               Set Brightness Mode"
	echo "AspectRatio    4:3|16:9|16:10|LBX|Native|Auto|Auto235|
               Auto235_Subtitle|Superwide|Auto3D|Status
                                               Set Aspect Ratio, or get status"
	echo "DisplayMode    Presentation|Bright|Cinema|sRGB-Reference-Standard|User|User2|
               Blackboard|Classroom|3D|DICOMSIM|Film|Game|Cinema|Vivid|ISFDay|
               ISFNight|ISF3D|2DHS|BlendingMode|Sport|HDR|HDRSim|Status
                                               Set Display Mode, or get status"
	echo "ColorTemp      Standard|D65|Cool|D75|Cold|D83|Warm|
               D55|D93|Native|Bright|Status|Reset
                                               Set Color Temperature, reset or get status"
	echo "BrilliantColor 1|2|3|4|5|6|7|8|9|10            Set Brilliantcolor™"
	echo "Mute           On|Off|Status                   Mute, unmute, or get status"
	echo "Volume         0|1|2|3|4|5|6|7|8|9|10          Set volume 0-10"
	echo "Input          hdmi1|hdmi2|hdmi3|dvi-d|dvid|dvia|dvi-a|vga|vga1|vga2|component|svideo|s-video|
               displayport|hdbaset|bnc|wireless|flashdrive|networkdisplay|usbdisplay|
               multimedia|3gsdi|3g-sdi|smarttv|status|state|-s
                                               Set input, or get status"
	echo "3DMode         Off|DLP-Link|IR/Vesa    Put 3D Mode"
	echo "RemoteControl  power|poweroff|mouseup|mouseleft|mouseenter|mouseright|mousedown|mouseleftclick|
               mouserightclick|up|left|enter|right|down|vkeystone+|vkeystone-|volume-|volume+|
               brightness|menu|zoom|dvid|dvi-d|vga1|avmute|svideo|s-video|vga2|video|contrast|
               freeze|lensshift|zoom+|zoom-|focus+|focus-|mode|aspectratio|12vtriggeron|
               12vtriggeroff|info|re-sync|resync|hdmi1|hdmi2|bnc|component|source|
               1|2|3|4|5|6|7|8|9|0|gamma|pip|lenshleft|lenshright|lensvleft|lensvright|
               hkeystone+|hkeystone-|hotkeyf1|hotkeyf2|hotkeyf3|pattern|"exit"|hdmi3|
               displayport|mute|3d|db|sleeptimer|home|"return"
                                               Send remote control commands"
}

if [ $# = 0 ]; then
	help
	exit
fi

# Default IP address and port:
IP_ADDRESS=192.168.1.30
TELNET_PORT=23

# Detailed command
# Real command looks like that : LeadCode ProjectorID CommandID space variable CarriageReturn
# ~XXXXX n CR
LEAD_CODE="~"
PROJECTOR_ID=01

# usage: telnoptoma command
telnoptoma () {
	echo -en "${1}\r" | nc -n4 -w 1 ${IP_ADDRESS} ${TELNET_PORT} | tr '\r' '\n' | tr -d '\0'
}

fanspeed () {
COMMAND_VALUE=""
for (( COMMAND_VALUE=1; COMMAND_VALUE<=4; COMMAND_VALUE++ )); do
TELNET_COMMAND=${LEAD_CODE}${PROJECTOR_ID}"351 ${COMMAND_VALUE}"

	# Fan speed
    COMMAND="Fan ${COMMAND_VALUE} Speed"
	RES=$(telnoptoma "${TELNET_COMMAND}")
	case ${RES:22:2} in
		F|"")  STATUS="Unrecognised command!";;
		Ok) if [[ ${RES:24:4} =~ ^-?[0-9]+$ ]]
				then STATUS="${RES:24:4}"
				else STATUS="Unrecognised Fan speed (${RES:24:4})"
				fi;;
		*)  STATUS="Unrecognised Fan Speed status!";;
	esac
	echo "${COMMAND}: ${STATUS}"
done
}

systemp () {
COMMAND="System Temperature"
TELNET_COMMAND=${LEAD_CODE}${PROJECTOR_ID}"352 1"

	# Systemp temperature
	RES=$(telnoptoma "${TELNET_COMMAND}")
	case ${RES:22:2} in
		F|"")  STATUS="Unrecognised command!";;
		Ok) if [[ ${RES:24:4} =~ ^-?[0-9]+$ ]]
				then STATUS="${RES:24:4}"
				else STATUS="Unrecognised System Temperature (${RES:24:4})"
				fi;;
		*)  STATUS="Unrecognised System Temperature status!";;
	esac
	echo "${COMMAND}: ${STATUS}"
}

filterusage () {
COMMAND="Filter Usage Hours"
TELNET_COMMAND=${LEAD_CODE}${PROJECTOR_ID}"321 1"

	# Filter Usage Hours
	RES=$(telnoptoma "${TELNET_COMMAND}")
	case ${RES:22:2} in
		F|"")  STATUS="Unrecognised command!";;
		Ok) if [[ ${RES:24:4} =~ ^-?[0-9]+$ ]]
				then STATUS="${RES:24:4} hours"
				else STATUS="Unrecognised Filter Usage Hours (${RES:24:4})"
				fi;;
		*)  STATUS="Unrecognised Filter Usage Hours status!";;
	esac
	echo "${COMMAND}: ${STATUS}"
}

powermode () {
COMMAND="Power Mode"
TELNET_COMMAND=${LEAD_CODE}${PROJECTOR_ID}"150 16"

	# Power Mode
	RES=$(telnoptoma "${TELNET_COMMAND}")
	case ${RES:22:2} in
		Ok) case ${RES:24:1} in
				1) STATUS="Active";;
				0) STATUS="Eco.";;
        esac;;
		F|"") STATUS="Unrecognised command!";;
		*) STATUS="Unrecognised status! (${RES:22:2})";;
	esac
	echo "${COMMAND}: ${STATUS}"
}

currentwatt () {
COMMAND="Current Watt"
TELNET_COMMAND=${LEAD_CODE}${PROJECTOR_ID}"358 1"

	# Systemp temperature
    COMMAND="Current Watt"
	RES=$(telnoptoma "${TELNET_COMMAND}")
	case ${RES:22:2} in
		F|"")  STATUS="Unrecognised command!";;
		Ok) if [[ ${RES:24:4} =~ ^-?[0-9]+$ ]]
				then STATUS="${RES:24:4}"
			else STATUS="Unrecognised Current Watt (${RES:24:4})"
			fi;;
		*)  STATUS="Unrecognised Current Watt status!";;
	esac
	echo "${COMMAND}: ${STATUS}"
}

information () {
COMMAND="Information"
TELNET_COMMAND=${LEAD_CODE}${PROJECTOR_ID}"150 1"

	# Information
	RES=$(telnoptoma "${TELNET_COMMAND}")
	case ${RES:22:2} in
		F|"") STATUS="Unrecognised command!";;
		Ok) case ${RES:24:1} in
			0) STATUS="Off";;
			1) STATUS="On";;
			*) STATUS="Unrecognised status! (${RES:24:1})";;
		   esac
		   echo "Status:            ${STATUS}"
		   case ${RES:25:5} in
			*) if [[ ${RES:25:5} = +([0-9][0-9][0-9][0-9][0-9]) ]]
				then STATUS="${RES:25:5} hours"
			else STATUS="Unrecognised Hours value (${RES:25:5})"
				fi;;
		   esac
		   echo "Lamp hour:         ${STATUS}"
		   case ${RES:30:2} in
			00) STATUS="None";;
			01) STATUS="DVI";;
			02) STATUS="VGA1";;
			03) STATUS="VGA2";;
			04) STATUS="S-Video";;
			05) STATUS="Video";;
			06) STATUS="BNC";;
			07) STATUS="HDMI1";;
			08) STATUS="HDMI2";;
			09) STATUS="Wireless";;
			10) STATUS="Component";;
			11) STATUS="Flash drive";;
			12) STATUS="Network Display";;
			13) STATUS="USB Display";;
			14) STATUS="HDMI3";;
			15) STATUS="DisplayPort";;
			16) STATUS="HDBaseT";;
			17) STATUS="Media";;
			*)  STATUS="Unrecognised status! (${RES:30:2})";;
		   esac
		   echo "Source:            ${STATUS}"
		   case ${RES:32:4} in
			*) STATUS="${RES:32:4}";;
		   esac
		   echo "Firmware version:  ${STATUS}"
		   case ${RES:36:2} in
			00) STATUS="None";;
			01) STATUS="Presentation";;
			02) STATUS="Bright";;
			03) STATUS="Cinema";;
			04) STATUS="sRGB/Reference/Standard";;
			05) STATUS="User";;
			06) STATUS="User2";;
			07) STATUS="Blackboard";;
			08) STATUS="Classroom";;
			09) STATUS="3D";;
			10) STATUS="DICOM SIM.";;
			11) STATUS="Film";;
			12) STATUS="Game";;
			13) STATUS="Cinema";;
			14) STATUS="Vivid";;
			15) STATUS="ISF Day";;
			16) STATUS="ISF Night";;
			17) STATUS="ISF 3D";;
			18) STATUS="2D High Speed";;
			19) STATUS="Blending Mode";;
			20) STATUS="Sport";;
			21) STATUS="HDR";;
			22) STATUS="HDR Sim";;
			*)  STATUS="Unrecognised status! (${RES:36:2})";;
		   esac
		   echo "Display mode:      ${STATUS}"
		   ;;
	esac
	RES=$(telnoptoma)
}

otherinformation () {    ##may take time
COMMAND_VALUE=""
for (( COMMAND_VALUE=2; COMMAND_VALUE<=20; COMMAND_VALUE++ )); do
TELNET_COMMAND=${LEAD_CODE}${PROJECTOR_ID}"150 ${COMMAND_VALUE}"
info=([2]="Native Resolution  " [3]="Main Source        " [4]="- Resolution       " [5]="- Signal Format    " [6]="- Pixel Clock      " [7]="- Horz Refresh     " [8]="- Vert Refresh     " [9]="Sub Source         " [10]="- Resolution       " [11]="- Signal Format    " [12]="- Pixel Clock      " [13]="- Horz Refresh     " [14]="- Vert Refresh     " [15]="Light Source Mode  " [16]="Standby Power Mode " [17]="DHCP               " [18]="System Temperature " [19]="Refresh rate       " [20]="Current Lamp Source")

	# Other information
    COMMAND="${info[COMMAND_VALUE]}"
	RES=$(telnoptoma "${TELNET_COMMAND}")
	case ${RES:22:2} in
		F|"")  STATUS="Unrecognised command!";;
		Ok) case ${RES:24:1} in
			3)      case ${RES:25:1} in
					"")     case ${COMMAND_VALUE} in
							20)    STATUS="Current Lamp Source: Both";;
							esac;;
					*)    STATUS="${RES:24}";;
					esac;;
			2)      case ${RES:25:1} in
					"")     case ${COMMAND_VALUE} in
							16)    STATUS="Standby Power Mode Eco.";;
							20)    STATUS="Current Lamp Source: Lamp2";;
							esac;;
					*)    STATUS="${RES:24}";;
					esac;;
			1)      case ${RES:25:1} in
					"")     case ${COMMAND_VALUE} in
							16)    STATUS="Standby Power Mode Active";;
							17)    STATUS="DHCP On";;
							20)    STATUS="Current Lamp Source: Lamp1";;
							esac;;
					*)    STATUS="${RES:24}";;
					esac;;
			0)		case ${RES:25:1} in
					"")     case ${COMMAND_VALUE} in
							17)    STATUS="DHCP Off";;
							esac;;
					*)    STATUS="${RES:24}";;
					esac;;
			*)	STATUS="${RES:24}";;
            esac;;
		*)  STATUS="Unrecognised ${COMMAND} status!";;
	esac
	echo "${COMMAND}: ${STATUS}"
done
}

power () {
	case $1 in
		on|1)
			COMMAND="Power On"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}00 1"
			;;
		off|of|0)
			COMMAND="Power Off"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}00 2"
			;;
		status|state|-s|?)
			COMMAND="Power Status"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}150 1"
			;;
	esac

	# Power control
	RES=$(telnoptoma "${TELNET_COMMAND}")
	case ${RES:22:2} in
		Ok) case ${RES:24:1} in
			1)    STATUS="Power on";;
			0)    STATUS="Power off";;
            esac;;
		F|"") STATUS="Unrecognised command!";;
		*) STATUS="Unrecognised status! (${RES:22:2})";;
	esac
	echo "${COMMAND}: ${STATUS}"
}

brightness () {
	case $1 in
		bright|-b)
			COMMAND="Bright"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}110 1"
			;;
		eco|-e)
			COMMAND="Eco"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}110 2"
			;;
		ecoplus|eco-plus|-eplus)
			COMMAND="Eco+"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}110 3"
			;;
		dynamic|-d)
			COMMAND="Dynamic"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}110 4"
			;;
		dboff)
			COMMAND="DynamicBlack Off"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}191 0"
			;;
		db1)
			COMMAND="DynamicBlack 1"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}191 1"
			;;
		db2)
			COMMAND="DynamicBlack 2"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}191 2"
			;;
		db3)
			COMMAND="DynamicBlack 3"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}191 3"
			;;
	esac

	# Brightness control
	RES=$(telnoptoma "${TELNET_COMMAND}")
	case ${RES:22:1} in
		F|"") 	case ${RES:24:1} in
						F|"") STATUS="Unrecognised command!";;
        		P) STATUS="Pass!";;
        		*) STATUS="Unrecognised brightness! (${RES:24})";;
        esac;;
		P) STATUS="Pass!";;
		*) STATUS="Unrecognised brightness! (${RES:22:1})";;
	esac
	echo "${COMMAND}: ${STATUS}"
}

aspectratio () {
	case $1 in
		"4:3"|1)
			COMMAND="4:3"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}60 1"
			;;
		"16:9"|2)
			COMMAND="16:9"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}60 2"
			;;
		"16:10"|3)
			COMMAND="16:10"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}60 3"
			;;
		LBX|5)
			COMMAND="LBX"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}60 5"
			;;
		native|6)
			COMMAND="Native"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}60 6"
			;;
		auto|7)
			COMMAND="Auto"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}60 7"
			;;
		auto235|8)
			COMMAND="Auto235"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}60 8"
			;;
		superwide|9)
			COMMAND="Superwide"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}60 9"
			;;
		auto235_subtitle|11)
			COMMAND="Auto235_Subtitle"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}60 11"
			;;
		auto3d|12)
			COMMAND="Auto 3D"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}60 12"
			;;
    status|state|?)
      COMMAND="Status"
      TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}127 1"
      ;;
	esac

	# Format control
	RES=$(telnoptoma "${TELNET_COMMAND}")
    case ${RES:22:1} in
    	P)	STATUS="Pass!";;
			F)	case ${RES:24:2} in
					P)  STATUS="Pass!";;
          Ok) case ${RES:26:2} in
							F)	STATUS="Fail!";;
          		01) STATUS="4:3";;
							02) STATUS="16:9";;
							03) STATUS="16:10";;
							05) STATUS="LBX";;
							06) STATUS="Native";;
							07) STATUS="Auto";;
							08) STATUS="Auto235";;
							09) STATUS="Superwide";;
							11) STATUS="Auto235_Subtitle";;
							12) STATUS="Auto 3D";;
          		*) 	STATUS="Already in that format! (${RES:26:2})";;
          		esac;;
      P)	STATUS="Pass!";;
			*)	STATUS="Fail!";;
			esac;;
		*)    STATUS="2Unrecognised format! (${RES:24:2})";;
	esac
	echo "${COMMAND}: ${STATUS}"
}

displaymode () {
	case $1 in
		presentation|1)
			COMMAND="Presentation"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}20 1"
			;;
		bright|2)
			COMMAND="Bright"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}20 3"
			;;
		cinema|3)
			COMMAND="Cinema"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}20 3"
			;;
		srgb|reference|standard|4)
			COMMAND="sRGB/Reference/Standard"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}20 4"
			;;
		user|5)
			COMMAND="User"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}20 5"
			;;
		user2|6)
			COMMAND="User2"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}20 6"
			;;
		blackboard|7)
			COMMAND="Blackboard"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}20 7"
			;;
		classroom|8)
			COMMAND="Classroom"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}20 8"
			;;
		3d|9)
			COMMAND="3D"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}20 9"
			;;
		dicom|dicomsim|10)
			COMMAND="DICOM SIM."
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}20 10"
			;;
		film|11)
			COMMAND="Film"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}20 11"
			;;
		game|12)
			COMMAND="Game"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}20 12"
			;;
		cinema|13)
			COMMAND="Cinema"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}20 13"
			;;
		vivid|14)
			COMMAND="Vivid"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}20 14"
			;;
		isfday|15)
			COMMAND="ISF Day"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}20 15"
			;;
		isfnight|16)
			COMMAND="ISF Night"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}20 16"
			;;
		isf3d|17)
			COMMAND="ISF 3D"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}20 17"
			;;
		2dhs|2dhighspeed|18)
			COMMAND="2D High Speed"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}20 18"
			;;
		blending|blendingmode|19)
			COMMAND="Bending Mode"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}20 19"
			;;
		sport|20)
			COMMAND="Sport"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}20 20"
			;;
		hdr|21)
			COMMAND="HDR"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}20 21"
			;;
		hdrsim|22)
			COMMAND="HDR Sim"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}20 22"
			;;
		state|status|-s|?)
			COMMAND="Status"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}123 1"
			;;
	esac

	# Display mode control
	RES=$(telnoptoma "${TELNET_COMMAND}")
    case ${RES:22:1} in
    	P)	STATUS="Pass!";;
			F)	case ${RES:24:2} in
          Ok) case ${RES:26:2} in
							F)	STATUS="Fail!";;
							00) STATUS="None";;
							01) STATUS="Presentation";;
							02) STATUS="Bright";;
							03) STATUS="Cinema";;
							04) STATUS="sRGB/Reference/Standard";;
							05) STATUS="User";;
							06) STATUS="User2";;
							07) STATUS="Blackboard";;
							08) STATUS="Classroom";;
							09) STATUS="3D";;
							10) STATUS="DICOM SIM.";;
							11) STATUS="Film";;
							12) STATUS="Game";;
							13) STATUS="Cinema";;
							14) STATUS="Vivid";;
							15) STATUS="ISF Day";;
							16) STATUS="ISF Night";;
							17) STATUS="ISF 3D";;
							18) STATUS="2D High Speed";;
							19) STATUS="Blending Mode";;
							20) STATUS="Sport";;
							21) STATUS="HDR";;
							22) STATUS="HDR Sim";;
							"")	STATUS="Already in that Display mode!";;
							*)  STATUS="Unrecognised display mode! (${RES:26:2})";;
              esac;;
					*)	STATUS="Unrecognised command!";;
			esac;;
		"")	STATUS="Unrecognised command!";;
		*)  STATUS="Unrecognised display mode! (${RES:24:2})";;
	esac
	echo "${COMMAND}: ${STATUS}"
}

colortemp () {
	case $1 in
		standard|d65|1)
			COMMAND="Standard D65"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}36 1"
			;;
		cool|d75|2)
			COMMAND="Cool D75"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}36 2"
			;;
		cold|d83|3)
			COMMAND="Cold D83"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}36 3"
			;;
		warm|d55|4)
			COMMAND="Warm D55"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}36 4"
			;;
		native|bright|5)
			COMMAND="Native (Bright)"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}36 5"
			;;
		d93|6)
			COMMAND="D93"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}36 6"
			;;
		reset|-r)
			COMMAND="Reset"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}33 1"
			;;
		state|status|-s)
			COMMAND="Status"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}128 1"
	esac

	# Color temperature control
	RES=$(telnoptoma "${TELNET_COMMAND}")
    case ${RES:22:1} in
    	P)	STATUS="Pass!";;
		F)	case ${RES:24:2} in
          Ok)     case ${RES:26:1} in
          			  0) STATUS="Standard";;
									1) STATUS="Cool D55";;
									2) STATUS="Cold D65";;
									3) STATUS="Warm";;
									4) STATUS="D75";;
									5) STATUS="D83";;
									6) STATUS="D93";;
									7) STATUS="Native (Bright)";;
                  "") STATUS="Already in that Color temperature!";;
                  esac;;
          P)	STATUS="Pass!";;
			*)	STATUS="Fail!";;
			esac;;
		"")	STATUS="Unrecognised command!";;
		*)  STATUS="2Unrecognised format! (${RES:24:2})";;
	esac
	echo "${COMMAND}: ${STATUS}"
}

brilliantcolor () {
	case $1 in
		1)
			COMMAND="BrilliantColor™ 1"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}34 1"
			;;
		2)
			COMMAND="BrilliantColor™ 2"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}34 2"
			;;
		3)
			COMMAND="BrilliantColor™ 3"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}34 3"
			;;
		4)
			COMMAND="BrilliantColor™ 4"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}34 4"
			;;
		5)
			COMMAND="BrilliantColor™ 5"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}34 5"
			;;
		6)
			COMMAND="BrilliantColor™ 6"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}34 6"
			;;
		7)
			COMMAND="BrilliantColor™ 7"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}34 7"
			;;
		8)
			COMMAND="BrilliantColor™ 8"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}34 8"
			;;
		9)
			COMMAND="BrilliantColor™ 9"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}34 9"
			;;
		10)
			COMMAND="BrilliantColor™ 10"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}34 10"
			;;
	esac

	# Brilliant color control
	RES=$(telnoptoma "${TELNET_COMMAND}")
	case ${RES:22:1} in
		F|"") case ${RES:24:1} in
					"")	STATUS="Unrecognised command!";;
        	*)  STATUS="Fail!";;
        	esac;;
		P) STATUS="Pass!";;
		*) STATUS="Unrecognised Brilliant color! (${RES:22:1})";;
	esac
	echo "${COMMAND}: ${STATUS}"
}

mute () {
	case $1 in
		off|0)
			COMMAND="Unmute"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}80 0"
			;;
		on|1)
			COMMAND="Mute"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}80 1"
			;;
		status|state|-s|?)
			COMMAND="Mute Status"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}356 1"
			;;
	esac

	# Mute control
	RES=$(telnoptoma "${TELNET_COMMAND}")
	case ${RES:22:2} in
		Ok) 	case ${RES:24:1} in
						1)    STATUS="Mute on";;
						0)    STATUS="Mute off";;
            esac;;
		F|"") STATUS="Unrecognised command!";;
		*) STATUS="Unrecognised status! (${RES:22:2})";;
	esac
	echo "${COMMAND}: ${STATUS}"
}

volume () {
	case $1 in
		0)
			COMMAND="Volume 0"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}81 0"
			;;
		1)
			COMMAND="Volume 1"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}81 1"
			;;
		2)
			COMMAND="Volume 2"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}81 2"
			;;
		3)
			COMMAND="Volume 3"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}81 3"
			;;
		4)
			COMMAND="Volume 4"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}81 4"
			;;
		5)
			COMMAND="Volume 5"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}81 5"
			;;
		6)
			COMMAND="Volume 6"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}81 6"
			;;
		7)
			COMMAND="Volume 7"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}81 7"
			;;
		8)
			COMMAND="Volume 8"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}81 8"
			;;
		9)
			COMMAND="Volume 9"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}81 9"
			;;
		10)
			COMMAND="Volume 10"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}81 10"
			;;
	esac

	# Audio control
	RES=$(telnoptoma "${TELNET_COMMAND}")
	case ${RES:22:2} in
		P) STATUS="Pass!";;
		F) STATUS="Fail!";;
		*) STATUS="Unrecognised Volume! (${RES:22:2})";;
	esac
	echo "${COMMAND}: ${STATUS}"
}
3dmode () {
	case $1 in
		off|0)
			COMMAND="Off"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}230 0"
			;;
		dlplink|dlp-link|dlp)
			COMMAND="DLP-Link"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}230 1"
			;;
		irvesa|ir-vesa|ir|vesa|ir/vesa)
			COMMAND="IR / VESA"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}230 2"
			;;
	esac

	# 3D Mode control
	RES=$(telnoptoma "${TELNET_COMMAND}")
	case ${RES:22:2} in
		P) STATUS="Pass!";;
		F|"") STATUS="Unrecognised command!";;
		*) STATUS="Unrecognised 3D Mode! (${RES:22:2})";;
	esac
	echo "${COMMAND}: ${STATUS}"
}

input () {
	case $1 in
		hdmi1|1)
			COMMAND="HDMI1 HDMI/MHL HDMI1/MHL"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}12 1"
			;;
		dvid|dvi-d|2)
			COMMAND="DVI-D"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}12 2"
			;;
		dvia|dvi-a|3)
			COMMAND="DVI-A"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}12 3"
			;;
		bnc|4)
			COMMAND="BNC"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}12 4"
			;;
		vga1|5)
			COMMAND="VGA VGA1"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}12 5"
			;;
		vga2|6)
			COMMAND="VGA2"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}12 6"
			;;
		svideo|s-video|9)
			COMMAND="S-Video"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}12 9"
			;;
		video|10)
			COMMAND="Video"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}12 10"
			;;
		wireless|11)
			COMMAND="Wireless"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}12 11"
			;;
		component|14)
			COMMAND="Component"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}12 14"
			;;
		hdmi2|15)
			COMMAND="HDMI2 HDMI2/MHL"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}12 15"
			;;
		hdmi3|16)
			COMMAND="HDMI3"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}12 16"
			;;
		flashdrive|17)
			COMMAND="Flash Drive"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}12 17"
			;;
		networkdisplay|18)
			COMMAND="Network Display"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}12 18"
			;;
		usbdisplay|19)
			COMMAND="USB Display"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}12 19"
			;;
		displayport|20)
			COMMAND="DisplayPort"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}12 20"
			;;
		hdbaset|21)
			COMMAND="HDBaseT"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}12 21"
			;;
		3g-sdi|3gsdi|22)
			COMMAND="3G-SDI"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}12 22"
			;;
		multimedia|23)
			COMMAND="Multimedia"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}12 23"
			;;
		smarttv|24)
			COMMAND="Smart TV"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}12 24"
			;;
		status|state|-s|?)
			COMMAND="Status"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}121 1"
	esac

	# Input control
	RES=$(telnoptoma "${TELNET_COMMAND}")
    case ${RES:22:1} in
    P)	STATUS="Pass!";;
		F)	case ${RES:24:2} in
          Ok)   case ${RES:26:1} in
					F) STATUS="Fail!";;
          0) STATUS="None";;
					1)  case ${RES:27:1} in
							0) STATUS="Wireless";;
							1) STATUS="Component";;
							2) STATUS="Flash Drive";;
							3) STATUS="Network Display";;
							4) STATUS="USB Display";;
							5) STATUS="DisplayPort";;
							6) STATUS="HDBaseT";;
							7) STATUS="Multimedia";;
							8) STATUS="3G-SDI";;
							"") STATUS="DVI-D/DVI-A";;
							esac;;
					2)  case ${RES:27:1} in
							0) STATUS="Smart TV";;
							"") STATUS="VGA1";;
							esac;;
					3) STATUS="VGA2";;
					4) STATUS="S-Video";;
					5) STATUS="Video";;
					6) STATUS="BNC";;
					7) STATUS="HDMI1 HDMI1/HML";;
					8) STATUS="HDMI2 HDMI2/HML";;
					9) STATUS="HDMI3";;
          "")STATUS="Already in that Input! (${RES:26:2})";;
          *) STATUS="Unrecognised Input! (${RES:26:2})";;
          esac;;
        P)	STATUS="Pass!";;
			"")	STATUS="Unrecognised command!";;
			*)	STATUS="Fail!";;
			esac;;
		"")  STATUS="Unrecognised command";;
		*)   STATUS="2Unrecognised format! (${RES:24:2})";;
	esac
	echo "${COMMAND}: ${STATUS}"
}

remotecontrol () {
	case $1 in
		power)
			COMMAND="Power"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}140 1"
			;;
		poweroff)
			COMMAND="Power Off"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}140 2"
			;;
		mouseup)
			COMMAND="Remote Mouse Up"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}140 3"
			;;
		mouseleft)
			COMMAND="Remote Mouse Left"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}140 4"
			;;
		mouseenter)
			COMMAND="Remote Mouse Enter"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}140 5"
			;;
		mouseright)
			COMMAND="Remote Mouse Right"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}140 6"
			;;
		mousedown)
			COMMAND="Remote Mouse Down"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}140 7"
			;;
		mouseleftclick)
			COMMAND="Mouse Left Click"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}140 8"
			;;
		mouserightclick)
			COMMAND="Mouse Right Click"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}140 9"
			;;
		up)
			COMMAND="Up"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}140 10"
			;;
		left)
			COMMAND="left"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}140 11"
			;;
		enter)
			COMMAND="Enter"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}140 12"
			;;
		right)
			COMMAND="Right"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}140 13"
			;;
		down)
			COMMAND="Down"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}140 14"
			;;
		vkeystone+)
			COMMAND="V Keystone +"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}140 15"
			;;
		vkeystone-)
			COMMAND="V Keystone -"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}140 16"
			;;
		volume-)
			COMMAND="Volume -"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}140 17"
			;;
		volume+)
			COMMAND="Volume +"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}140 18"
			;;
		brightness)
			COMMAND="Brightness"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}140 19"
			;;
		menu)
			COMMAND="Menu"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}140 20"
			;;
		zoom)
			COMMAND="Zoom"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}140 21"
			;;
		dvid|dvi-d)
			COMMAND="DVI-D"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}140 22"
			;;
		vga1)
			COMMAND="VGA-1"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}140 23"
			;;
		avmute)
			COMMAND="AV Mute"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}140 24"
			;;
		svideo|s-video)
			COMMAND="S-Video"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}140 25"
			;;
		vga2)
			COMMAND="VGA-2"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}140 26"
			;;
		video)
			COMMAND="Video"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}140 27"
			;;
		contrast)
			COMMAND="Contrast"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}140 28"
			;;
		freeze)
			COMMAND="Freeze"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}140 30"
			;;
		lensshift)
			COMMAND="Lens shift"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}140 31"
			;;
		zoom+)
			COMMAND="Zoom+"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}140 32"
			;;
		zoom-)
			COMMAND="Zoom-"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}140 33"
			;;
		focus+)
			COMMAND="Focus+"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}140 34"
			;;
		focus-)
			COMMAND="Focus-"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}140 35"
			;;
		mode)
			COMMAND="Mode"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}140 36"
			;;
		aspectratio)
			COMMAND="Aspect Ratio"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}140 37"
			;;
		12vtriggeron)
			COMMAND="12V Trigger On"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}140 38"
			;;
		12vtriggeroff)
			COMMAND="12V Trigger Off"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}140 39"
			;;
		info)
			COMMAND="info"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}140 40"
			;;
		re-sync|resync)
			COMMAND="Re-sync"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}140 41"
			;;
		hdmi1)
			COMMAND="HDMI1"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}140 42"
			;;
		hdmi2)
			COMMAND="HDMI2"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}140 43"
			;;
		bnc)
			COMMAND="BNC"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}140 44"
			;;
		component)
			COMMAND="Component"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}140 45"
			;;
		source)
			COMMAND="Source"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}140 47"
			;;
		1)
			COMMAND="1"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}140 51"
			;;
		2)
			COMMAND="2"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}140 52"
			;;
		3)
			COMMAND="3"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}140 53"
			;;
		4)
			COMMAND="4"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}140 54"
			;;
		5)
			COMMAND="5"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}140 55"
			;;
		6)
			COMMAND="6"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}140 56"
			;;
		7)
			COMMAND="7"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}140 57"
			;;
		8)
			COMMAND="8"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}140 58"
			;;
		9)
			COMMAND="9"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}140 59"
			;;
		0)
			COMMAND="0"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}140 60"
			;;
		gamma)
			COMMAND="Gamma"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}140 61"
			;;
		pip)
			COMMAND="PIP"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}140 63"
			;;
		lenshleft)
			COMMAND="Lens H Left"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}140 64"
			;;
		lenshright)
			COMMAND="Lens H Right"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}140 65"
			;;
		lensvleft)
			COMMAND="Lens V Left"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}140 66"
			;;
		lensvright)
			COMMAND="Lens V Right"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}140 67"
			;;
		hkeystone+)
			COMMAND="H Keystone -"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}140 68"
			;;
		hkeystone-)
			COMMAND="H Keystone +"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}140 69"
			;;
		hotkeyf1)
			COMMAND="Hot Key F1"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}140 70"
			;;
		hotkeyf2)
			COMMAND="Hot Key F2"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}140 71"
			;;
		hotkeyf3)
			COMMAND="Hot Key F3"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}140 72"
			;;
		pattern)
			COMMAND="Pattern"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}140 73"
			;;
		"exit")
			COMMAND="Exit"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}140 74"
			;;
		hdmi3)
			COMMAND="HDMI3"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}140 75"
			;;
		displayport)
			COMMAND="DisplayPort"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}140 76"
			;;
		mute)
			COMMAND="Mute"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}140 77"
			;;
		3d)
			COMMAND="3D"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}140 78"
			;;
		db)
			COMMAND="DB"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}140 79"
			;;
		sleeptimer)
			COMMAND="Sleep Timer"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}140 80"
			;;
		home)
			COMMAND="Home"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}140 81"
			;;
		"return")
			COMMAND="Return"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}140 82"
			;;
	esac

	# Brightness control
	RES=$(telnoptoma "${TELNET_COMMAND}")
	case ${RES:22:1} in
		F) 	case ${RES:24:1} in
				F) STATUS="Fail!";;
                P) STATUS="Pass!";;
				"")	STATUS="Unrecognised command!";;
                *) STATUS="Fail!";;
            esac;;
		P) STATUS="Pass!";;
		*) STATUS="Fail! (${RES:22:1})";;
	esac
	echo "${COMMAND}: ${STATUS}"
}

COMMAND=$(echo "$1" | tr "A-Z" "a-z")
PARAMETER=$(echo "$2" | tr "A-Z" "a-z")
case $COMMAND in
	information)	if [ $# -ge 2 ]; then IP_ADDRESS=$2; fi
		if [ $# -ge 3 ]; then TELNET_PORT=$3; fi
		if [ $# -gt 3 ]; then echo "Error: Too many parameters!"; usage; exit; fi
		information
		;;
	otherinformation)	if [ $# -ge 2 ]; then IP_ADDRESS=$2; fi
		if [ $# -ge 3 ]; then TELNET_PORT=$3; fi
		if [ $# -gt 3 ]; then echo "Error: Too many parameters!"; usage; exit; fi
		otherinformation
		;;
	power)	case $PARAMETER in
			on|off|of|-s|status|state|1|0|?)
				if [ $# -ge 3 ]; then IP_ADDRESS=$3; fi
				if [ $# -ge 4 ]; then TELNET_PORT=$4; fi
				if [ $# -gt 4 ]; then echo "Error: Too many parameters!"; usage; exit; fi
				power "$PARAMETER"
				;;
			"")	echo "Error: No Parameter supplied for $PARAMETER command"
				usage
				;;
			*)	echo "Error: Unknown Parameter for $PARAMETER command: '$2'"
				usage
				;;
		esac
		;;
	brightness)	case $PARAMETER in
			bright|eco|ecoplus|eco-plus|-eplus|dynamic|dboff|db1|db2|db3|-b|-e|-d)
				if [ $# -ge 3 ]; then IP_ADDRESS=$3; fi
				if [ $# -ge 4 ]; then TELNET_PORT=$4; fi
				if [ $# -gt 4 ]; then echo "Error: Too many parameters!"; usage; exit; fi
				brightness "$PARAMETER"
				;;
			"")	echo "Error: No Parameter supplied for $PARAMETER command"
				usage
				;;
			*)	echo "Error: Unknown Parameter for $PARAMETER command: '$2'"
				usage
				;;
		esac
		;;
	aspectratio)	case $PARAMETER in
			"4:3"|"16:9"|"16:10"|lbx|native|auto|auto235|auto235_subtitle|superwide|auto3d|1|2|3|5|6|7|8|9|11|12|status|state|-s|?)
				if [ $# -ge 3 ]; then IP_ADDRESS=$3; fi
				if [ $# -ge 4 ]; then TELNET_PORT=$4; fi
				if [ $# -gt 4 ]; then echo "Error: Too many parameters!"; usage; exit; fi
				aspectratio "$PARAMETER"
				;;
			"")	echo "Error: No Parameter supplied for $PARAMETER command"
				usage
				;;
			*)	echo "Error: Unknown Parameter for $PARAMETER command: '$2'"
				usage
				;;
		esac
		;;
	displaymode|display)	case $PARAMETER in
			presentation|bright|cinema|srgb|reference|standard|user|user2|blackboard|classroom|3d|dicom|dicomsim|film|game|cinema|vivid|isfday|isfnight|isf3d|2dhs|2dhighspeed|blendingmode|blending|sport|hdr|hdrsim|1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|state|status|-s|?)
				if [ $# -ge 3 ]; then IP_ADDRESS=$3; fi
				if [ $# -ge 4 ]; then TELNET_PORT=$4; fi
				if [ $# -gt 4 ]; then echo "Error: Too many parameters!"; usage; exit; fi
				displaymode "$PARAMETER"
				;;
			"")	echo "Error: No Parameter supplied for $PARAMETER command"
				usage
				;;
			*)	echo "Error: Unknown Parameter for $PARAMETER command: '$2'"
				usage
				;;
		esac
		;;
	colortemp)	case $PARAMETER in
			standard|d65|cool|d75|cold|d83|warm|d55|d93|native|bright|reset|state|status|1|2|3|4|5|6|-s|-r)
				if [ $# -ge 3 ]; then IP_ADDRESS=$3; fi
				if [ $# -ge 4 ]; then TELNET_PORT=$4; fi
				if [ $# -gt 4 ]; then echo "Error: Too many parameters!"; usage; exit; fi
				colortemp "$PARAMETER"
				;;
			"")	echo "Error: No Parameter supplied for $PARAMETER command"
				usage
				;;
			*)	echo "Error: Unknown Parameter for $PARAMETER command: '$2'"
				usage
				;;
		esac
		;;
	brilliantcolor)	case $PARAMETER in
			1|2|3|4|5|6|7|8|9|10)
				if [ $# -ge 3 ]; then IP_ADDRESS=$3; fi
				if [ $# -ge 4 ]; then TELNET_PORT=$4; fi
				if [ $# -gt 4 ]; then echo "Error: Too many parameters!"; usage; exit; fi
				brilliantcolor "$PARAMETER"
				;;
			"")	echo "Error: No Parameter supplied for $PARAMETER command"
				usage
				;;
			*)	echo "Error: Unknown Parameter for $PARAMETER command: '$2'"
				usage
				;;
		esac
		;;
	mute)	case $PARAMETER in
			on|off|0|1|status|state|-s|?)
				if [ $# -ge 3 ]; then IP_ADDRESS=$3; fi
				if [ $# -ge 4 ]; then TELNET_PORT=$4; fi
				if [ $# -gt 4 ]; then echo "Error: Too many parameters!"; usage; exit; fi
				mute "$PARAMETER"
				;;
			"")	echo "Error: No Parameter supplied for $PARAMETER command"
				usage
				;;
			*)	echo "Error: Unknown Parameter for $PARAMETER command: '$2'"
				usage
				;;
		esac
		;;
    volume)	case $PARAMETER in
			0|1|2|3|4|5|6|7|8|9|10|status|state|-s|?)
				if [ $# -ge 3 ]; then IP_ADDRESS=$3; fi
				if [ $# -ge 4 ]; then TELNET_PORT=$4; fi
				if [ $# -gt 4 ]; then echo "Error: Too many parameters!"; usage; exit; fi
				volume "$PARAMETER"
				;;
			"")	echo "Error: No Parameter supplied for $PARAMETER command"
				usage
				;;
			*)	echo "Error: Unknown Parameter for $PARAMETER command: '$2'"
				usage
				;;
		esac
		;;
		3dmode)	case $PARAMETER in
			off|0|dlp-link|dlplink|dlp|ir-vesa|irvesa|ir|vesa|ir/vesa)
				if [ $# -ge 3 ]; then IP_ADDRESS=$3; fi
				if [ $# -ge 4 ]; then TELNET_PORT=$4; fi
				if [ $# -gt 4 ]; then echo "Error: Too many parameters!"; usage; exit; fi
				3dmode "$PARAMETER"
				;;
			"")	echo "Error: No Parameter supplied for $PARAMETER command"
				usage
				;;
			*)	echo "Error: Unknown Parameter for $PARAMETER command: '$2'"
				usage
				;;
		esac
		;;
    input)	case $PARAMETER in
			hdmi1|hdmi2|hdmi3|dvi-d|dvid|dvia|dvi-a|vga|vga1|vga2|component|svideo|s-video|displayport|hdbaset|bnc|wireless|flashdrive|networkdisplay|usbdisplay|multimedia|3gsdi|3g-sdi|smarttv|status|state|-s|?)
				if [ $# -ge 3 ]; then IP_ADDRESS=$3; fi
				if [ $# -ge 4 ]; then TELNET_PORT=$4; fi
				if [ $# -gt 4 ]; then echo "Error: Too many parameters!"; usage; exit; fi
				input "$PARAMETER"
				;;
			"")	echo "Error: No Parameter supplied for $PARAMETER command"
				usage
				;;
			*)	echo "Error: Unknown Parameter for $PARAMETER command: '$2'"
				usage
				;;
		esac
		;;
    remotecontrol)	case $PARAMETER in
			power|poweroff|mouseup|mouseleft|mouseenter|mouseright|mousedown|mouseleftclick|mouserightclick|up|left|enter|right|down|vkeystone+|vkeystone-|volume-|volume+|brightness|menu|zoom|dvid|dvi-d|vga1|avmute|svideo|s-video|vga2|video|contrast|freeze|lensshift|zoom+|zoom-|focus+|focus-|mode|aspectratio|12vtriggeron|12vtriggeroff|info|re-sync|resync|hdmi1|hdmi2|bnc|component|source|1|2|3|4|5|6|7|8|9|0|gamma|pip|lenshleft|lenshright|lensvleft|lensvright|hkeystone+|hkeystone-|hotkeyf1|hotkeyf2|hotkeyf3|pattern|"exit"|hdmi3|displayport|mute|3d|db|sleeptimer|home|"return")
				if [ $# -ge 3 ]; then IP_ADDRESS=$3; fi
				if [ $# -ge 4 ]; then TELNET_PORT=$4; fi
				if [ $# -gt 4 ]; then echo "Error: Too many parameters!"; usage; exit; fi
				remotecontrol "$PARAMETER"
				;;
			"")	echo "Error: No Parameter supplied for $PARAMETER command"
				usage
				;;
			*)	echo "Error: Unknown Parameter for $PARAMETER command: '$2'"
				usage
				;;
		esac
		;;
	help)	help
		;;
	fanspeed)	if [ $# -ge 2 ]; then IP_ADDRESS=$2; fi
		if [ $# -ge 3 ]; then TELNET_PORT=$3; fi
		if [ $# -gt 3 ]; then echo "Error: Too many parameters!"; usage; exit; fi
		fanspeed
		;;
	systemp)	if [ $# -ge 2 ]; then IP_ADDRESS=$2; fi
		if [ $# -ge 3 ]; then TELNET_PORT=$3; fi
		if [ $# -gt 3 ]; then echo "Error: Too many parameters!"; usage; exit; fi
		systemp
		;;
	currentwatt)	if [ $# -ge 2 ]; then IP_ADDRESS=$2; fi
		if [ $# -ge 3 ]; then TELNET_PORT=$3; fi
		if [ $# -gt 3 ]; then echo "Error: Too many parameters!"; usage; exit; fi
		currentwatt
		;;
	filterusage)	if [ $# -ge 2 ]; then IP_ADDRESS=$2; fi
		if [ $# -ge 3 ]; then TELNET_PORT=$3; fi
		if [ $# -gt 3 ]; then echo "Error: Too many parameters!"; usage; exit; fi
		filterusage
		;;
	powermode)	if [ $# -ge 2 ]; then IP_ADDRESS=$2; fi
		if [ $# -ge 3 ]; then TELNET_PORT=$3; fi
		if [ $# -gt 3 ]; then echo "Error: Too many parameters!"; usage; exit; fi
		powermode
		;;
	*)	echo "Error: Unknown Command: '$1'"
		usage
		;;
esac
