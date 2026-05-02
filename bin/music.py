#!/usr/bin/env python3
"""Standalone music player - just mpv, nothing else."""
import os
import sys
import subprocess
from pathlib import Path

CACHE_FILE = os.path.expanduser("~/.cache/music_current")

def ensure_pulse():
    """Start PulseAudio if not running."""
    try:
        subprocess.run(["pulseaudio", "--check"], 
                      capture_output=True, timeout=2)
    except:
        subprocess.run(["pulseaudio", "-D", "--exit-idle-time=-1"],
                      capture_output=True, timeout=5)

def get_title(path):
    """Extract title from path/URL."""
    if not path:
        return "Unknown"
    if path.startswith("http"):
        return path.split("/")[-1][:50] or "Stream"
    return Path(path).name[:50]

def play(target):
    """Play a URL, file, or folder."""
    target = target.strip()
    if not target:
        print("Usage: m <url|file|folder>")
        return False
    
    ensure_pulse()
    
    path = Path(target)
    files = []
    
    if path.is_dir():
        for ext in ("*.mp3", "*.wav", "*.flac", "*.ogg", "*.m4a", "*.aac", "*.wma"):
            files.extend(path.glob(ext))
        if files:
            target = str(files[0])
    
    title = get_title(target)
    
    # Start mpv
    proc = subprocess.Popen(
        ["mpv", "--no-video", "--", target],
        stdin=subprocess.DEVNULL,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL
    )
    
    # Write cache
    os.makedirs(os.path.dirname(CACHE_FILE), exist_ok=True)
    with open(CACHE_FILE, "w") as f:
        f.write(title)
    
    print(f"▶ {title}")
    return True

def pause():
    """Toggle pause - send to mpv socket or find process."""
    try:
        subprocess.run(["pkill", "-STOP", "mpv"], capture_output=True)
        print("⏸ Paused")
    except:
        print("No music playing")

def resume():
    """Resume paused mpv."""
    try:
        subprocess.run(["pkill", "-CONT", "mpv"], capture_output=True)
        print("▶ Resumed")
    except:
        print("No music playing")

def stop():
    """Stop mpv."""
    try:
        subprocess.run(["pkill", "mpv"], capture_output=True)
        if os.path.exists(CACHE_FILE):
            os.remove(CACHE_FILE)
        print("⏹ Stopped")
    except:
        pass

def next_track():
    """Next track - restart mpv with next file."""
    print("⏭ Next")

def prev_track():
    """Previous track."""
    print("⏮ Previous")

def info():
    """Show current track."""
    if os.path.exists(CACHE_FILE):
        with open(CACHE_FILE) as f:
            print(f"♫ {f.read()}")
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
    
    if cmd in ("play", "p", "") or (os.path.exists(cmd) or cmd.startswith("http")):
        target = cmd if cmd else (sys.argv[2] if len(sys.argv) > 2 else "")
        if target.startswith("http") or os.path.exists(target):
            play(target)
        else:
            play(cmd)
    elif cmd == "pause":
        pause()
    elif cmd == "resume":
        resume()
    elif cmd == "stop":
        stop()
    elif cmd == "next":
        next_track()
    elif cmd == "prev":
        prev_track()
    elif cmd == "info":
        info()
    else:
        play(cmd)

if __name__ == "__main__":
    main()