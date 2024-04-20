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
    "󰈐 Power profile": ["Quit", "Balance", "Performance"],
    "🚀 GPU mode": ["Integrated", "Hybrid"]
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
    if selected_category == "🚀 GPU mode":
        title = "🚀 Select GPU mode"

    selected_item = run_wofi_with_items(title, selected_items)

    print(f"Selected: {selected_item.strip()}")


if __name__ == "__main__":
    if len(sys.argv) != 1:
        if "menu" in sys.argv:
            show_menu()
    else:
        pass
