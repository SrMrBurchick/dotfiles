#!/bin/sh
WALLPAPER=$(find ~/Wallpapers/*.jpg | shuf -n1)

function load_wp(){
     swaybg -m fill -i "$WALLPAPER"
}

load_wp
