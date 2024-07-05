#!/usr/bin/env python3

import subprocess
import json
import sys


# Generate a list of items dynamically
def generate_items():
    for i in range(1, 6):
        yield f"Option {i}"


# Define the categories and items
categories = {
    "󰈐 Power profile": ["Quiet", "Balanced", "Performance"],
    "🎮 GPU mode": ["Integrated", "Hybrid"]
}


power_profiles = {
    "Quiet": {
        "icon":"🛸",
        "tooltip": "UFO mode"
    },
    "Balanced": {
        "icon":"🛫",
        "tooltip":"Jet mode"
    },
    "Performance": {
        "icon":"🚀",
        "tooltip":"Rocket mode"
    }
}


def run_wofi_with_items(title, items):
    proc_cat = subprocess.Popen(["wofi", "--dmenu", "--prompt", title, "--format", "f"], stdin=subprocess.PIPE, stdout=subprocess.PIPE, text=True)
    selected, _ = proc_cat.communicate("\n".join(items))
    return selected


def switch_power_profile(new_profile):
    pass


def switch_gpu_mode(new_mode):
    pass


# Create a subprocess to run wofi
def show_menu():
    # Create a list of category names
    category_names = list(categories.keys())

    selected_category = run_wofi_with_items("Asusctl Menu", category_names)

    selected_items = categories.get(selected_category.strip(), [])

    title = "󰈐 Select power profile"
    if selected_category == "🎮 GPU mode":
        title = "🎮 Select GPU mode"

    selected_item = run_wofi_with_items(title, selected_items)

    print(f"Selected: {selected_item.strip()}")


def get_active_profile():
    proc_cat = subprocess.Popen(["asusctl", "profile", "-p"], stdin=subprocess.PIPE, stdout=subprocess.PIPE, text=True)
    selected, _ = proc_cat.communicate()
    result = selected.split()
    return result[len(result) - 1]


def asus_module():
    profile = get_active_profile()
    obj = power_profiles.get(profile)
    return {"text": obj["icon"] + profile, "tooltip": obj["tooltip"], "icon": obj["icon"], "state": ""}


if __name__ == "__main__":
    if len(sys.argv) != 1:
        if "menu" in sys.argv:
            show_menu()
    else:
        print(json.dumps(asus_module()))
