#!/bin/bash

WALLPAPER_PATH=""
WALLPAPER=$(find $WALLPAPER_PATH/*.gif | shuf -n1)

function load_wp(){
    swww img -t any --transition-bezier 0.0,0.0,1.0,1.0 --transition-duration .8 --transition-step 255 --transition-fps 60 $WALLPAPER
}

load_wp
