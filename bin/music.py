#!/usr/bin/env python3
"""Standalone music player - just mpv."""
import os
import sys
import subprocess
import time
from pathlib import Path

MPV_SOCKET = "/tmp/mpvsocket"
CACHE_FILE = os.path.expanduser("~/.cache/music_current")

def ensure_pulse():
    """Start PulseAudio if not running, or skip if fails."""
    # Check if already running
    try:
        result = subprocess.run(["pulseaudio", "--check"], capture_output=True, timeout=2)
        if result.returncode == 0:
            return True
    except:
        pass
    
    # Try to start PulseAudio
    try:
        subprocess.run(["pulseaudio", "-D", "--exit-idle-time=-1"], capture_output=True, timeout=5)
        time.sleep(1)
        result = subprocess.run(["pulseaudio", "--check"], capture_output=True, timeout=2)
        if result.returncode == 0:
            return True
    except:
        pass
    
    print("PulseAudio not available, using default audio")
    return False

def get_mpv_title():
    if not os.path.exists(MPV_SOCKET):
        return None
    try:
        result = subprocess.run(
            ["socat", "-", MPV_SOCKET],
            input=b"get_property media-title\n",
            capture_output=True, timeout=2
        )
        title = result.stdout.decode().strip()
        if title and title != "null" and len(title) > 3:
            return title
    except:
        pass
    return None

def get_title_from_url(url):
    if not url.startswith("http"):
        return None
    try:
        result = subprocess.run(
            ["yt-dlp", "--flat-playlist", "--print", "%title", url],
            capture_output=True, text=True, timeout=10
        )
        if result.stdout.strip():
            return result.stdout.strip()[:50]
    except:
        pass
    return None

def get_title_from_file(path):
    if not path:
        return "Unknown"
    if path.startswith("http"):
        title = get_title_from_url(path)
        if title:
            return title
        return path.split("/")[-1][:50] or "Stream"
    try:
        result = subprocess.run(
            ["ffprobe", "-v", "error", "-show_entries", 
             "format_tags=title",
             "-of", "default=noprint_wrappers=1:nokey=1",
             path],
            capture_output=True, text=True, timeout=5
        )
        if result.stdout.strip():
            return result.stdout.strip()[:50]
    except:
        pass
    return Path(path).stem[:50]

def play(target):
    target = target.strip()
    if not target:
        print("Usage: m <url|file|folder>")
        return
    
    ensure_pulse()
    
    path = Path(target)
    
    if path.is_dir():
        files = list(path.glob("*.mp3")) + list(path.glob("*.wav")) + \
               list(path.glob("*.flac")) + list(path.glob("*.ogg")) + \
               list(path.glob("*.m4a")) + list(path.glob("*.aac"))
        if not files:
            print("No audio files found")
            return
        target = str(files[0])
        path = Path(target)
    
    title = get_title_from_file(str(Path(target).resolve()))
    
    # Try to get title BEFORE playing (works for URLs)
    if target.startswith("http"):
        pre_title = get_title_from_url(target)
        if pre_title:
            title = pre_title
    
    subprocess.run(["pkill", "mpv"], capture_output=True)
    time.sleep(0.5)
    
    mpv_args = [
        "mpv",
        "--input-ipc-server=" + MPV_SOCKET,
        "--no-video",
        "--", target
    ]
    
    proc = subprocess.Popen(
        mpv_args,
        stdin=subprocess.DEVNULL,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL
    )
    
    time.sleep(2)
    real_title = get_mpv_title()
    if real_title and real_title != title:
        title = real_title
    
    os.makedirs(os.path.dirname(CACHE_FILE), exist_ok=True)
    with open(CACHE_FILE, "w") as f:
        f.write(title)
    
    print(f"▶ {title}")

def pause_toggle():
    title = get_mpv_title()
    if title:
        print(f"⏸ {title}")
    else:
        print("No music playing")

def stop():
    subprocess.run(["pkill", "mpv"], capture_output=True)
    if os.path.exists(CACHE_FILE):
        os.remove(CACHE_FILE)
    print("⏹ Stopped")

def info():
    title = get_mpv_title()
    if not title and os.path.exists(CACHE_FILE):
        with open(CACHE_FILE) as f:
            title = f.read()
    
    if title:
        print(f"♫ {title}")
    else:
        print("No track playing")

def main():
    if len(sys.argv) < 2:
        print("Music Player")
        print("Usage: m <url|file|folder>")
        print("       m pause")
        print("       m stop")
        print("       m info")
        return
    
    cmd = sys.argv[1]
    
    if cmd in ("play", "p") or os.path.exists(cmd) or cmd.startswith("http"):
        target = sys.argv[2] if len(sys.argv) > 2 else cmd
        play(target or cmd)
    elif cmd == "pause":
        pause_toggle()
    elif cmd == "stop":
        stop()
    elif cmd == "info":
        info()
    else:
        play(cmd)

if __name__ == "__main__":
    main()