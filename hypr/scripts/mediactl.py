#!/usr/bin/env python3

import subprocess
import sys
import json


def get_player_info():
    try:
        output = subprocess.check_output(
            "playerctl metadata --format '{{status}}'",
            shell=True,
            universal_newlines=True,
        )
        status = output.strip()
        output = subprocess.check_output(
            "playerctl metadata --format '{{artist}}'",
            shell=True,
            universal_newlines=True,
        )

        artist = output.strip()
        output = subprocess.check_output(
            "playerctl metadata --format '{{title}}'",
            shell=True,
            universal_newlines=True,
        )

        title = output.strip()
        return {"status": status, "title": title, "artist": artist}
    except subprocess.CalledProcessError:
        return {"status": "unknown", "title": None, "artist": None}


def prev_next(IsPrev: bool):
    if IsPrev:
        subprocess.run("playerctl previous", shell=True)
        subprocess.run("dunstify \"Play next\"", shell=True)
        subprocess.run("dunstify \"Play previous\"", shell=True)
    else:
        subprocess.run("playerctl next", shell=True)
        subprocess.run("dunstify \"Play next\"", shell=True)


def toggle():
    player_info = get_player_info()
    if player_info["status"] == "Playing":
        subprocess.run("dunstify \"Stop playing\"", shell=True)
    else:
        subprocess.run("dunstify \"Continue playing\"", shell=True)

    subprocess.run("playerctl play-pause", shell=True)


def media_module():
    media_info = get_player_info()
    if media_info["status"] == "unknown":
        icon = ""
    elif "Playing" == media_info["status"]:
        icon = "▶"
    else:
        icon = "⏸"
    artist = media_info["artist"]
    title = media_info["title"]
    tooltip = f"{title} - {artist}"
    return {"text": icon, "tooltip": tooltip}


if __name__ == "__main__":
    if len(sys.argv) != 1:
        if "toggle" in sys.argv:
            toggle()
        elif "next" in sys.argv:
            prev_next(False)
        elif "prev" in sys.argv:
            prev_next(True)
    else:
        print(json.dumps(media_module()))
