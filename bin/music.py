#!/usr/bin/env python3
"""Standalone music player - just mpv."""
import os
import sys
import subprocess
import time
import json
from pathlib import Path
from datetime import datetime

MPV_SOCKET = os.path.expanduser("~/.cache/mpv_socket")
CACHE_FILE = os.path.expanduser("~/.cache/music_current")
HISTORY_FILE = os.path.expanduser("~/.cache/music_history")

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
    
    add_to_history(title, target)
    print(f"󰝚 {title}")

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
            print(f"󰐎 {title}")
    except:
        print("Failed to toggle pause")

def stop():
    subprocess.run(["pkill", "mpv"], capture_output=True)
    if os.path.exists(CACHE_FILE):
        os.remove(CACHE_FILE)
    print("󰐎 Stopped")

def info():
    title = get_mpv_title()
    if not title and os.path.exists(CACHE_FILE):
        with open(CACHE_FILE) as f:
            title = f.read()
    
    if title:
        print(f"󰝚 {title}")
    else:
        print("No track playing")

def add_to_history(title, target):
    """Add played track to history."""
    os.makedirs(os.path.dirname(HISTORY_FILE), exist_ok=True)
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    with open(HISTORY_FILE, "a") as f:
        f.write(f"{timestamp} | {title} | {target}\n")

def show_history():
    """Display playback history."""
    if not os.path.exists(HISTORY_FILE):
        print("No history found")
        return
    with open(HISTORY_FILE) as f:
        lines = f.readlines()
    if not lines:
        print("History is empty")
        return
    print("Recent History (last 20):")
    for i, line in enumerate(lines[-20:], 1):
        print(f"{i}. {line.strip()}")

def replay(choice=None):
    """Replay a track from history."""
    if not os.path.exists(HISTORY_FILE):
        print("No history found")
        return
    with open(HISTORY_FILE) as f:
        lines = f.readlines()
    if not lines:
        print("History is empty")
        return
    
    if choice is None:
        # Replay last track
        last = lines[-1].strip()
        parts = last.split(" | ")
        if len(parts) >= 3:
            target = parts[2]
            title = parts[1]
            print(f"Replaying: {title}")
            play(target)
        else:
            print("Invalid history entry")
        return
    
    # If choice is a number, try to play that entry
    try:
        idx = int(choice)
        if 1 <= idx <= len(lines):
            entry = lines[idx-1].strip()
            parts = entry.split(" | ")
            if len(parts) >= 3:
                target = parts[2]
                title = parts[1]
                print(f"Replaying: {title}")
                play(target)
            else:
                print("Invalid history entry")
        else:
            print(f"Index out of range (1-{len(lines)})")
    except ValueError:
        print("Invalid index")

def seek(seconds):
    """Seek forward (positive) or backward (negative) by seconds."""
    if not os.path.exists(MPV_SOCKET):
        print("No music playing")
        return
    try:
        cmd = json.dumps({"command": ["seek", str(seconds), "relative"]}) + "\n"
        subprocess.run(
            ["socat", "-", MPV_SOCKET],
            input=cmd.encode(),
            capture_output=True, timeout=2
        )
        print(f"Seeked {seconds:+} seconds")
    except Exception as e:
        print(f"Seek failed: {e}")

def watch():
    """Watch and display music info in real-time.

    Simplified layout: [icon] Title <bar> time
    Uses Tokyo Night palette (yellow, blue, purple, green).
    """
    socket_path = os.path.expanduser("~/.cache/mpv_socket")

    # Tokyo Night theme colors (matching tmux config exactly)
    # Convert hex to ANSI 256-color approximations
    C_ICON = "\033[38;5;210m"    # #f7768e - red/pink for icon
    C_TITLE = "\033[38;5;74m"    # #7aa2f7 - blue for title
    C_BAR = "\033[38;5;59m"      # #24283b - dark blue for bar
    C_TIME = "\033[38;5;150m"    # #9ece6a - green for time
    C_RESET = "\033[0m"
    C_BOLD = "\033[1m"

    if not os.path.exists(socket_path):
        print("No music playing")
        return

    title = "Unknown"
    if os.path.exists(CACHE_FILE):
        with open(CACHE_FILE) as f:
            title = f.read().strip()

    print(f"{C_BOLD}{C_ICON}󰊄{C_RESET} {C_BOLD}{C_TITLE}Watching... Ctrl+C to exit{C_RESET}")
    print("")
    print("")
    print("")  # Extra space between header and music display

    while True:
        try:
            # Query mpv for time/duration/pause
            result = subprocess.run(
                ["socat", "-", socket_path],
                input=b'{"command":["get_property","time-pos"]}\n{"command":["get_property","duration"]}\n{"command":["get_property","pause"]}\n',
                capture_output=True, timeout=2
            )

            lines = [l for l in result.stdout.decode().split('\n') if l.startswith('{')]

            pos = dur = 0
            paused = False
            for i, line in enumerate(lines):
                try:
                    d = json.loads(line)
                    val = d.get('data')
                    if val is not None:
                        if i == 0: pos = float(val)
                        elif i == 1: dur = float(val)
                        elif i == 2: paused = bool(val)
                except: continue

            # Get title directly from mpv for accuracy
            try:
                res = subprocess.run(
                    ["socat", "-", socket_path],
                    input=b'{"command":["get_property","media-title"]}\n',
                    capture_output=True, timeout=2
                )
                d = json.loads(res.stdout.decode().strip())
                if d.get('data'): title = str(d.get('data'))[:40]
            except: pass

            if not title:
                print("\nNo track playing")
                break

            # Time formatting
            p_min, p_sec = int(pos // 60), int(pos % 60)
            d_min, d_sec = int(dur // 60), int(dur % 60)

            # Progress bar (gray bar with muted tip)
            bar_size = 30
            filled = int((pos / dur) * bar_size) if dur > 0 else 0
            filled = max(0, min(filled, bar_size))
            
            # Build bar cleanly
            filled_chars = "━" * filled
            empty_chars = "─" * (bar_size - filled)
            
            if 0 < filled < bar_size:
                # Replace last filled char with tip, color the transition
                bar = f"{C_BAR}{filled_chars[:-1]}{C_TIME}╸{C_BAR}{empty_chars}{C_RESET}"
            else:
                bar = f"{C_BAR}{filled_chars}{empty_chars}{C_RESET}"

            icon = f"{C_ICON}󰝚{C_RESET}" if not paused else f"{C_ICON}󰐎{C_RESET}"

            # UI: ICON TITLE [BAR] TIME
            out = f"{icon} {C_TITLE}{title:40}{C_RESET} {bar}  {C_TIME}{p_min:02d}:{p_sec:02d}/{d_min:02d}:{d_sec:02d}{C_RESET}"
            
            print(f"\r{out}\033[K", end='', flush=True)

            time.sleep(1)

        except KeyboardInterrupt: break
        except: break

    print(f"\n{C_TITLE}Stopped{C_RESET}")

def search(query, auto_select_first=False):
    """Search for music and let user select."""
    print(f"󰊄 Searching for: {query}")
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
        
        if auto_select_first:
            print(f"Auto-playing first result: {results[0]}")
            play(urls[0])
            return
        
        # Check if fzf is available for scrolling selection
        use_fzf = False
        try:
            subprocess.run(["which", "fzf"], capture_output=True, check=True)
            use_fzf = True
        except:
            pass
        
        if use_fzf:
            # Use fzf for interactive selection
            import tempfile
            with tempfile.NamedTemporaryFile(mode='w', delete=False) as f:
                for r in results:
                    f.write(r + '\n')
                temp_name = f.name
            try:
                fzf_result = subprocess.run(
                    ["fzf", "--height=40%", "--reverse"],
                    stdin=open(temp_name),
                    capture_output=True, text=True
                )
                if fzf_result.returncode == 0:
                    selected = fzf_result.stdout.strip()
                    try:
                        idx = int(selected.split('.')[0]) - 1
                        if 0 <= idx < len(urls) and urls[idx]:
                            play(urls[idx])
                    except:
                        print("Invalid selection")
                else:
                    print("Cancelled")
            finally:
                os.unlink(temp_name)
        else:
            # Fallback to numbered list
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
        print("Music Player - QoL Edition")
        print("Usage:")
        print("  m <url|file|folder>    - Play directly")
        print("  m <query>               - Auto-search and play first result")
        print("  m search <query>        - Search with selection (fzf if available)")
        print("  m history                - Show playback history")
        print("  m replay [index]        - Replay from history (last if no index)")
        print("  m seek <seconds>        - Seek forward/backward")
        print("  m forward [seconds]     - Seek forward (default 10s)")
        print("  m backward [seconds]    - Seek backward (default 10s)")
        print("  m watch                  - Watch with progress bar")
        print("  m pause                 - Toggle pause")
        print("  m stop                  - Stop playback")
        print("  m info                  - Show current track")
        return
    
    cmd = sys.argv[1]
    
    # Check if cmd is a file/directory/URL
    is_file = os.path.exists(cmd) or cmd.startswith("http")
    
    if cmd in ("play", "p"):
        target = sys.argv[2] if len(sys.argv) > 2 else None
        if not target:
            print("Usage: m play <url|file>")
            return
        play(target)
    elif is_file:
        play(cmd)
    elif cmd == "pause":
        pause_toggle()
    elif cmd == "stop":
        stop()
    elif cmd == "info":
        info()
    elif cmd == "watch":
        watch()
    elif cmd == "search":
        if len(sys.argv) < 3:
            print("Usage: m search <query>")
            return
        query = " ".join(sys.argv[2:])
        search(query)
    elif cmd == "history":
        show_history()
    elif cmd == "replay":
        choice = sys.argv[2] if len(sys.argv) > 2 else None
        replay(choice)
    elif cmd == "seek":
        if len(sys.argv) < 3:
            print("Usage: m seek <seconds>")
            return
        try:
            seconds = float(sys.argv[2])
            seek(seconds)
        except ValueError:
            print("Invalid seconds")
    elif cmd in ("forward", "fwd"):
        if len(sys.argv) > 2:
            seconds = float(sys.argv[2])
        else:
            seconds = 10
        seek(seconds)
    elif cmd in ("backward", "back"):
        if len(sys.argv) > 2:
            seconds = -float(sys.argv[2])
        else:
            seconds = -10
        seek(seconds)
    else:
        # Treat entire argument list as search query
        query = " ".join(sys.argv[1:])
        search(query, auto_select_first=True)

if __name__ == "__main__":
    main()
