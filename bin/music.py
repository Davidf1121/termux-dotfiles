#!/usr/bin/env python3
"""Standalone music player - just mpv, nothing else."""
import os
import sys
import subprocess
import time
from pathlib import Path

MPV_SOCKET = "/tmp/mpvsocket"
CACHE_FILE = os.path.expanduser("~/.cache/music_current")

def ensure_pulse():
    """Start PulseAudio if not running."""
    try:
        subprocess.run(["pulseaudio", "--check"], 
                      capture_output=True, timeout=2)
    except:
        subprocess.run(["pulseaudio", "-D", "--exit-idle-time=-1"],
                      capture_output=True, timeout=5)

def get_mpv_title():
    """Get actual title from mpv via socket."""
    if not os.path.exists(MPV_SOCKET):
        return None
    try:
        result = subprocess.run(
            ["socat", "-", MPV_SOCKET],
            input=b"get_property media-title\n",
            capture_output=True, timeout=2
        )
        title = result.stdout.decode().strip()
        if title and title != "null":
            return title
    except:
        pass
    return None

def get_title_from_file(path):
    """Extract title from file using ffprobe."""
    if not path or path.startswith("http"):
        return path.split("/")[-1][:50] if path else "Stream"
    
    try:
        result = subprocess.run(
            ["ffprobe", "-v", "error", "-show_entries", 
             "format_tags=title", "-of", "default=noprint_wrappers=1:nokey=1",
             path],
            capture_output=True, text=True, timeout=5
        )
        if result.stdout.strip():
            return result.stdout.strip()[:50]
    except:
        pass
    
    return Path(path).stem[:50]

def play(target):
    """Play a URL, file, or folder."""
    target = target.strip()
    if not target:
        print("Usage: m <url|file|folder>")
        return
    
    ensure_pulse()
    
    path = Path(target)
    files = []
    
    if path.is_dir():
        for ext in ["*.mp3", "*.wav", "*.flac", "*.ogg", "*.m4a", "*.aac", "*.wma"]:
            files.extend(path.glob(ext))
        if not files:
            print("No audio files found")
            return
        target = str(files[0])
        path = Path(target)
    
    title = get_title_from_file(str(path))
    
    # Kill existing mpv
    subprocess.run(["pkill", "mpv"], capture_output=True)
    
    # Start mpv with IPC
    proc = subprocess.Popen(
        ["mpv", "--profile=music", "--input-ipc-server=" + MPV_SOCKET, "--no-video", "--", target],
        stdin=subprocess.DEVNULL,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL
    )
    
    # Wait, then get real title
    time.sleep(1)
    real_title = get_mpv_title()
    if real_title:
        title = real_title
    
    # Write cache
    os.makedirs(os.path.dirname(CACHE_FILE), exist_ok=True)
    with open(CACHE_FILE, "w") as f:
        f.write(title)
    
    print(f"▶ {title}")

def pause_toggle():
    """Toggle pause."""
    title = get_mpv_title()
    if title:
        print(f"⏸ {title}")
    else:
        print("No music playing")

def stop():
    """Stop mpv."""
    subprocess.run(["pkill", "mpv"], capture_output=True)
    if os.path.exists(CACHE_FILE):
        os.remove(CACHE_FILE)
    print("⏹ Stopped")

def info():
    """Show current track."""
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