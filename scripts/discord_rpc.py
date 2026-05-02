import os
import time
import json
import requests
import subprocess

# --- Configuration ---
# To keep your token safe, create a file at ~/.discord_rpc.env with:
# TOKEN=your_token_here
ENV_FILE = os.path.expanduser("~/.env")

def get_token():
    if os.path.exists(ENV_FILE):
        with open(ENV_FILE, "r") as f:
            for line in f:
                if line.startswith("TOKEN="):
                    return line.split("=")[1].strip()
    return None

def get_sys_info():
    # Battery & Temp from cache
    battery = "..."
    temp = "..."
    cache_path = os.path.expanduser("~/.tmux_battery_cache")
    if os.path.exists(cache_path):
        try:
            with open(cache_path, "r") as f:
                data = json.load(f)
                status = "󰁹"
                if data.get("status") == "CHARGING": status = "󱐋"
                elif data.get("status") == "DISCHARGING": status = "󰂄"
                battery = f"{status} {data.get('percentage')}%"
                temp = f"󰏈 {data.get('temperature')}°C"
        except:
            pass

    # RAM
    try:
        ram = subprocess.check_output("free -m | awk '/Mem:/ { printf \"%dMB\", $3 }'", shell=True).decode().strip()
        ram = f"󰍛 {ram}"
    except:
        ram = "󰍛 ..."

    # CPU (using our tmux helper)
    try:
        cpu = subprocess.check_output("cut -c3- ~/.tmux.conf.local | sh -s cpu_usage", shell=True).decode().strip()
        cpu = f"󰻠 {cpu}"
    except:
        cpu = "󰻠 ..."

    return f"{battery} | {cpu} | {ram} | {temp}"

def update_status(token, text):
    url = "https://discord.com/api/v9/users/@me/settings"
    headers = {
        "Authorization": token,
        "Content-Type": "application/json"
    }
    payload = {
        "custom_status": {
            "text": text,
            "emoji_name": "termux", # You can change this to any emoji name
        }
    }
    try:
        r = requests.patch(url, headers=headers, json=payload)
        return r.status_code == 200
    except:
        return False

def main():
    token = get_token()
    if not token:
        print("❌ Error: TOKEN not found in ~/.discord_rpc.env")
        print("Please create the file and add: TOKEN=your_discord_token")
        return

    print("🚀 Discord RPC Started! Updating status every 60 seconds...")
    while True:
        status_text = get_sys_info()
        if update_status(token, status_text):
            print(f"✅ Updated: {status_text}")
        else:
            print("❌ Failed to update status. Check your token.")
        
        time.sleep(60)

if __name__ == "__main__":
    main()
