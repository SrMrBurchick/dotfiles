#!/bin/bash

WALLPAPER_PATH=""
WALLPAPER=$(find $WALLPAPER_PATH/*.gif | shuf -n1)
swww img $WALLPAPER &
