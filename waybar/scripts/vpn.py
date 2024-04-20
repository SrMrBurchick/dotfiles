#!/usr/bin/env python3

import subprocess
import json
import sys

VPN_NAME = "PingleVPN_Updated"


# Функція для отримання списку VPN
def get_vpn_list():
    vpn_list = []
    try:
        output = subprocess.check_output(
            "nmcli -t -f NAME,TYPE,STATE con | grep 'vpn:'",
            shell=True,
            universal_newlines=True,
        )

        vpn_list = output.strip().split("\n")
    except subprocess.CalledProcessError:
        pass

    return vpn_list


# Функція для генерації tooltip
def generate_tooltip():
    # tooltip = []
    tooltip = ""
    vpn_list_format = "{name} {state}\n"
    vpn_list = get_vpn_list()
    icon = ""

    for vpn in vpn_list:
        name, type, state = vpn.strip().split(":")
        if state != "":
            icon = ""
        # vpn_tooltip = {
        #     "label": vpn_list_format.format(name=name, state=icon),
        #     "exec": "notify-send \"{}\"".format(name)
        # }
        # tooltip.append(vpn_tooltip)
        tooltip += vpn_list_format.format(name=name, state=icon)

    return tooltip


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
            subprocess.run("notify-send \"VPN Connected\"", shell=True)
        else:
            subprocess.run("notify-send \"VPN connection failed\"", shell=True)
    else:
        result = subprocess.run(
            "nmcli con down {}".format(VPN_NAME), shell=True)
        if 0 == result.returncode:
            subprocess.run("notify-send \"VPN Disconnected\"", shell=True)
        else:
            subprocess.run("notify-send \"VPN failed to disconnect\"", shell=True)


# Функція для виводу інформації про VPN
def vpn_module():
    vpn_info = get_vpn_info()
    if vpn_info["name"] is not None:
        icon = ""
    else:
        icon = ""
    text = f"VPN: {icon}"
    return {"text": text, "tooltip": generate_tooltip(), "icon": icon, "state": vpn_info['state']}


if __name__ == "__main__":
    if len(sys.argv) != 1:
        if "toggle" in sys.argv:
            toggle_vpn()
        elif "list" in sys.argv:
            print(generate_tooltip())
    else:
        print(json.dumps(vpn_module()))
