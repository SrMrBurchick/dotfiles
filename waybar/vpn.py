#!/usr/bin/env python3

import subprocess
import json
import sys

VPN_NAME = ""


# Функція для отримання інформації про VPN
def get_vpn_info():
    try:
        output = subprocess.check_output(
            "nmcli -t -f NAME,TYPE,STATE con show --active | grep 'vpn:'",
            shell=True,
            universal_newlines=True,
        )
        name, type, state = output.strip().split(":")
        return {"name": name, "type": type, "state": state}
    except subprocess.CalledProcessError:
        return {"name": None, "type": None, "state": "disconnected"}


# Функція для зміни стану VPN
def toggle_vpn():
    vpn_info = get_vpn_info()
    if vpn_info["state"] == "disconnected":
        result = subprocess.run("nmcli con up {}".format(VPN_NAME), shell=True)
        if 0 == result.returncode:
            subprocess.run("dunstify \"VPN Connected\"", shell=True)
        else:
            subprocess.run("dunstify \"VPN connection failed\"", shell=True)
    else:
        result = subprocess.run(
            "nmcli con down {}".format(VPN_NAME), shell=True)
        if 0 == result.returncode:
            subprocess.run("dunstify \"VPN Disconnected\"", shell=True)
        else:
            subprocess.run("dunstify \"VPN failed to disconnect\"", shell=True)


# Функція для виводу інформації про VPN
def vpn_module():
    vpn_info = get_vpn_info()
    if vpn_info["name"] is not None:
        icon = ""
    else:
        icon = ""
    text = f"VPN: {icon}"
    return {"text": text, "tooltip": "Click to toggle VPN", "icon": icon, "state": vpn_info['state']}


if __name__ == "__main__":
    if len(sys.argv) != 1:
        if "toggle" in sys.argv:
            toggle_vpn()
    else:
        print(json.dumps(vpn_module()))
