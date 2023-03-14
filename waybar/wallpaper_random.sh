#!/bin/sh
WALLPAPER_PATH=""
WALLPAPER=$(find $WALLPAPER_PATH/*.jpg | shuf -n1)
swww img $WALLPAPER &

