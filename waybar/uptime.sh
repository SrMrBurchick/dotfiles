#!/usr/bin/env bash

WAYBAR_POWER_MENU_JSON_TEXT=""
eAYBAR_POWER_TOOLTIP=$(eval uptime -p)

WAYBAR_POWER_MENU_JSON="{
        \"text\":\"${WAYBAR_POWER_MENU_JSON_TEXT}\",
        \"tooltip\":\"${WAYBAR_POWER_TOOLTIP}\"
}\n"

echo $WAYBAR_POWER_MENU_JSON
