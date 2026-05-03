#!/usr/bin/env python3
"""Standalone music player - just mpv."""
import os
import sys
import subprocess
import time
import json
from pathlib import Path

MPV_SOCKET = os.path.expanduser("~/.cache/mpv_socket")
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
        time.sleep(2)
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
        # Use --simulate first to get title
        result = subprocess.run(
            ["yt-dlp", "--dump-json", "--no-playlist", url],
            capture_output=True, text=True, timeout=15
        )
        import json
        for line in result.stdout.strip().split('\n'):
            if line:
                data = json.loads(line)
                return data.get('title', url.split('/')[-1])[:50]
    except:
        pass
    # Fallback - extract from URL
    return url.split('/')[-1].replace('-', ' ')[:50] if '/' in url else url[:50]

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
    
    time.sleep(3)
    real_title = get_mpv_title()
    if real_title and real_title != title:
        title = real_title
    
    os.makedirs(os.path.dirname(CACHE_FILE), exist_ok=True)
    with open(CACHE_FILE, "w") as f:
        f.write(title)
    
    print(f"▶ {title}")

def pause_toggle():
    if not os.path.exists(MPV_SOCKET):
        print("No music playing")
        return

    try:
        # Toggle pause
        subprocess.run(
            ["socat", "-", MPV_SOCKET],
            input=b"cycle pause\n",
            capture_output=True, timeout=2
        )
        # Show status
        title = get_mpv_title()
        if title:
            print(f"⏯ {title}")
    except:
        print("Failed to toggle pause")

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

def search(query):
    """Search for music and let user select."""
    print(f"🔍 Searching for: {query}")
    try:
        result = subprocess.run(
            ["yt-dlp", "--flat-playlist", "--dump-json", 
             f"ytsearch10:{query}"],
            capture_output=True, text=True, timeout=30
        )
        results = []
        urls = []
        for line in result.stdout.strip().split('\n'):
            if line:
                try:
                    data = json.loads(line)
                    title = data.get('title', 'Unknown')[:50]
                    duration = data.get('duration')
                    if duration:
                        mins = int(duration // 60)
                        secs = int(duration % 60)
                        results.append(f"{len(results)+1}. {title} ({mins}:{secs:02d})")
                    else:
                        results.append(f"{len(results)+1}. {title}")
                    urls.append(data.get('url', data.get('webpage_url', '')))
                except:
                    pass
        
        if not results:
            print("No results found")
            return
        
        print("\nResults:")
        for r in results:
            print(r)
        print("\nSelect number (or Enter to cancel): ", end='')
        
        try:
            import sys
            choice = sys.stdin.readline().strip()
            if not choice:
                return
            idx = int(choice) - 1
            if 0 <= idx < len(results) and idx < len(urls) and urls[idx]:
                play(urls[idx])
        except (ValueError, IndexError):
            print("Cancelled")
    except Exception as e:
        print(f"Search failed: {e}")

def main():
    if len(sys.argv) < 2:
        print("Music Player")
        print("Usage: m <url|file|folder>")
        print("       m search <query>")
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
    elif cmd == "search":
        if len(sys.argv) < 3:
            print("Usage: m search <query>")
            return
        query = " ".join(sys.argv[2:])
        search(query)
    else:
        play(cmd)

if __name__ == "__main__":
    main()