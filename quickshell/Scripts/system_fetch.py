#!/usr/bin/env python3
import subprocess
import json
import os

def get_uptime():
    return subprocess.check_output(["uptime", "-p"]).decode().strip()

def get_username():
    return subprocess.check_output(["whoami"]).decode().strip()

def get_desktop_env():
    return os.environ.get("XDG_CURRENT_DESKTOP", "")

if __name__ == "__main__":
    fetch = {
        "user": get_username(),
        "uptime": get_uptime(),
        "desktop_env": get_desktop_env()
    }

    print(json.dumps(fetch))
