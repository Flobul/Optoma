#!/bin/bash

# Use echo -e "$(~/Applications/telnoptoma/uhd51.sh status)" to print all output at once

usage () {
	echo "Usage: $(basename $0) command [parameter] [ip-address [port]]"
}

help () {
	usage
	echo
	echo "Command  Parameter"
	echo "Information                                    Get current information of projector"
	echo "Power          On|Off|Status                   Turn projector on or off, or get power status"
	echo "Brightness     Bright|Eco|Eco+|Dynamyc|DynamicBlack Off|
               DynamicBlack 1|DynamicBlack 2|DynamicBlack 3|Status
                                               Turn brightness mode, eco mode, or get status"
	echo "ApectRatio     4:3|16:9|16:10|LBX|Native|Auto|Auto235|
               Auto235_Subtitle|Superwide|Auto3D|Status
                                               Set aspectratio 4:3, 16:9, 16:10, lbx, native, auto,
                                               auto235, auto235_subtitle, superwide, auto3D, or get status"
	echo "DisplayMode    None|Presentation|Bright|Cinema|sRGB-Reference-Standard|User|User2|
               Blackboard|Classroom|3D|DICOMSIM|Film|Game|Cinema|Vivid|ISFDay|
               ISFNight|ISF3D|2DHS|BlendingMode|Sport|HDR|HDRSim|Status
                                               Set display Mode, or get status"
	echo "ColorTemp      Standard|D65|Cool|D75|Cold|D83|Warm|
               D55|D93|Native|Bright|Status|Reset
                                               Set color temperature, reset or get status"
	echo "BrilliantColor 1|2|3|4|5|6|7|8|9|10            Set brilliantcolor 1-10"
	echo "Audio          Mute|Unmute|Status              Mute, unmute, or get status"
	echo "Volume         0|1|2|3|4|5|6|7|8|9|10          Set volume 0-10"
}

if [ $# = 0 ]; then
	help
	exit
fi

# Default IP address and port:
IP_ADDRESS=192.168.1.30
TELNET_PORT=23

# Detailed command
# Real command looks like : LeadCode ProjectorID CommandID space variable CarriageReturn
# ~XXXXX n CR
LEAD_CODE="~"
PROJECTOR_ID=01

# usage: telnoptoma command
telnoptoma () {
	echo -en "${1}\r" | nc -n4 -w 1 ${IP_ADDRESS} ${TELNET_PORT} | tr '\r' '\n' | tr -d '\0'
}

information () {
COMMAND="Information"
TELNET_COMMAND=${LEAD_CODE}${PROJECTOR_ID}"150 1"

	# Information
	RES=$(telnoptoma "${TELNET_COMMAND}")
	case ${RES:22:2} in
		F) STATUS="Fail!";;
		Ok) case ${RES:24:1} in
			0) STATUS="Off";;
			1) STATUS="On";;
			*) STATUS="Unrecognised status! (${RES:24:1})";;
		   esac
		   echo "Status:            ${STATUS}"
		   case ${RES:25:5} in
			*) STATUS="${RES:25:5} hours";;
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
		F) STATUS="Fail!";;
		*) STATUS="Unrecognised status! (${RES:22:2})";;
	esac
	echo "${COMMAND} : ${STATUS}"
}

brightness () {
	case $1 in
		bright|lumineux|-l)	
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
		F) 	case ${RES:24:1} in
				F) STATUS="Fail!";;
                P) STATUS="Pass!";;
                *) STATUS="Fail!";;
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
            Ok)   case ${RES:26:2} in
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
            Ok)   case ${RES:26:2} in
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
					*)  STATUS="Unrecognised display mode! (${RES:26:2})";;
                  esac;;
            P)	STATUS="Pass!";;
			*)	STATUS="Fail!";;
			esac;;
		*)    STATUS="2Unrecognised format! (${RES:24:2})";;
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
			COMMAND="reset"
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
            Ok)   case ${RES:26:1} in
					F) STATUS="Fail!";;
                    0) STATUS="Standard";;
					1) STATUS="Cool D55";;
					2) STATUS="Cold D65";;
					3) STATUS="Warm";;
					4) STATUS="D75";;
					5) STATUS="D83";;
					6) STATUS="D93";;
					7) STATUS="Native (Bright)";;
                    *) STATUS="Already in that format! (${RES:26:2})";;
                  esac;;
            P)	STATUS="Pass!";;
			*)	STATUS="Fail!";;
			esac;;
		*)    STATUS="2Unrecognised format! (${RES:24:2})";;
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
		F) 	case ${RES:24:1} in
				F) STATUS="Fail!";;
                P) STATUS="Pass!";;
                *) STATUS="Fail!";;
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
			COMMAND="Audio Status"
			TELNET_COMMAND="${LEAD_CODE}${PROJECTOR_ID}356 1"
			;;
	esac

	# Audio control
	RES=$(telnoptoma "${TELNET_COMMAND}")
	case ${RES:22:2} in
		Ok) case ${RES:24:1} in
			1)    STATUS="Mute on";;
			0)    STATUS="Mute off";;
            esac;;
		F) STATUS="Fail!";;
		*) STATUS="Unrecognised status! (${RES:22:2})";;
	esac
	echo "${COMMAND} : ${STATUS}"
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
		*) STATUS="Unrecognised status! (${RES:22:2})";;
	esac
	echo "${COMMAND} : ${STATUS}"
}

COMMAND=$(echo "$1" | tr "A-Z" "a-z")
PARAMETER=$(echo "$2" | tr "A-Z" "a-z")
case $COMMAND in
	information)	if [ $# -ge 2 ]; then IP_ADDRESS=$2; fi
		if [ $# -ge 3 ]; then TELNET_PORT=$3; fi
		if [ $# -gt 3 ]; then echo "Error: Too many parameters!"; usage; exit; fi
		information
		;;
	power)	case $PARAMETER in
			on|off|of|-s|status|1|0|?)
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
			bright|eco|ecoplus|eco-plus|-eplus|dynamic|dboff|db1|db2|db3|-l|-e|-d|?)
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
			"4:3"|"16:9"|"16:10"|lbx|native|auto|auto235|auto235_subtitle|superwide|auto3D|1|2|3|5|6|7|8|9|11|12|status|state|-s|?)
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
	help)	help
		;;
	*)	echo "Error: Unknown Command: '$1'"
		usage
		;;
esac
