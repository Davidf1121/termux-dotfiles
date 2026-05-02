import os
import time
import json
import requests
import subprocess

# --- Configuration ---
# To keep your token safe, create a file at ~/.env with:
# TOKEN=your_token_here
ENV_FILE = os.path.expanduser("~/.env")

def get_token():
    if os.path.exists(ENV_FILE):
        with open(ENV_FILE, "r") as f:
            for line in f:
                if line.startswith("TOKEN="):
                    return line.split("=")[1].strip().strip("'").strip('"')
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
                status = "🔋"
                if data.get("status") == "CHARGING": status = "🔌"
                elif data.get("status") == "DISCHARGING": status = "🔋"
                battery = f"{status} {data.get('percentage')}%"
                temp = f"🔥 {data.get('temperature')}°C"
        except:
            pass

    # RAM
    try:
        ram = subprocess.check_output("free -m | awk '/Mem:/ { printf \"%dMB\", $3 }'", shell=True).decode().strip()
        ram = f"💾 {ram}"
    except:
        ram = "💾 ..."

    # CPU (using our tmux helper)
    try:
        cpu = subprocess.check_output("cut -c3- ~/.tmux.conf.local | sh -s cpu_usage", shell=True).decode().strip()
        cpu = f"⚡ {cpu}"
    except:
        cpu = "⚡ ..."

    return f"{battery} | {cpu} | {ram} | {temp}"

def update_status(token, text):
    url = "https://discord.com/api/v9/users/@me/settings"
    headers = {
        "Authorization": token,
        "Content-Type": "application/json",
        "User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36"
    }
    payload = {
        "custom_status": {
            "text": text,
            "emoji_name": None,
        }
    }
    try:
        r = requests.patch(url, headers=headers, json=payload)
        return r
    except Exception as e:
        print(f"❌ Request failed: {e}")
        return None

def main():
    token = get_token()
    if not token:
        print("❌ Error: TOKEN not found in ~/.env")
        print("Please create the file and add: TOKEN=your_discord_token")
        return

    print("🚀 Discord RPC Started! Updating status every 60 seconds...")
    while True:
        status_text = get_sys_info()
        r = update_status(token, status_text)
        
        if r is not None:
            if r.status_code == 200:
                print(f"✅ Updated: {status_text}")
            else:
                print(f"❌ Discord API Error {r.status_code}: {r.reason}")
        else:
            print("❌ Failed to update status. Check your connection.")
        
        time.sleep(60)

if __name__ == "__main__":
    main()
