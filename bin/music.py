#!/usr/bin/env python3
import os
import sys
import subprocess
import signal
import json
import threading
from pathlib import Path

MPV_SOCKET = "/tmp/mpvsocket"
CACHE_FILE = os.path.expanduser("~/.cache/music_current")

class MusicPlayer:
    def __init__(self):
        self.player = None
        self.queue = []
        self.current = None
        self.paused = False
        
    def send_cmd(self, cmd):
        if os.path.exists(MPV_SOCKET):
            try:
                subprocess.run(["socat", "-", MPVSOCKET], 
                          input=cmd.encode(), 
                          capture_output=True,
                          timeout=2)
            except:
                pass
                
    def play(self, target):
        target = target.strip()
        if not target:
            print("Usage: play <url|file|folder>")
            return
            
        # Handle folder
        path = Path(target)
        if path.is_dir():
            files = list(path.glob("*.mp3")) + list(path.glob("*.wav")) + \
                   list(path.glob("*.flac")) + list(path.glob("*.ogg")) + \
                   list(path.glob("*.m4a")) + list(path.glob("*.aac"))
            if files:
                self.queue = [str(f) for f in files]
                target = self.queue[0]
                
        # Start mpv with IPC
        cmd = ["mpv", "--profile=music", "--", target]
        self.player = subprocess.Popen(cmd, 
                                    stdin=subprocess.DEVNULL,
                                    stdout=subprocess.DEVNULL,
                                    stderr=subprocess.DEVNULL)
        self.current = target
        self._update_cache()
        print(f"▶ Playing: {self._get_title()}")
        
    def pause(self):
        self.send_cmd("cycle pause\n")
        self.paused = not self.paused
        print(f"{'⏸ Paused' if self.paused else '▶ Resumed'}")
        
    def next(self):
        if len(self.queue) > 1:
            self.queue.pop(0)
            if self.queue:
                self.play(self.queue[0])
        else:
            self.send_cmd("playlist-next\n")
        print("⏭ Next track")
        
    def prev(self):
        self.send_cmd("playlist-prev\n")
        print("⏮ Previous track")
        
    def stop(self):
        self.send_cmd("quit\n")
        if self.player:
            self.player.terminate()
        self._clear_cache()
        print("⏹ Stopped")
        
    def vol(self, level):
        level = max(0, min(100, int(level or 100)))
        self.send_cmd(f"set volume {level}\n")
        print(f"🔊 Volume: {level}%")
        
    def info(self):
        title = self._get_title()
        if title:
            print(f"♫ {title}")
        else:
            print("No track playing")
            
    def _get_title(self):
        if not os.path.exists(MPV_SOCKET):
            return self.current or "Unknown"
        try:
            result = subprocess.run(["socat", "-", MPVSOCKET],
                                  input=b"get_property media-title\n",
                                  capture_output=True, timeout=2)
            title = result.stdout.decode().strip()
            return title if title else self.current or "Unknown"
        except:
            return self.current or "Unknown"
            
    def _update_cache(self):
        os.makedirs(os.path.dirname(CACHE_FILE), exist_ok=True)
        with open(CACHE_FILE, "w") as f:
            f.write(self.current or "")
            
    def _clear_cache(self):
        if os.path.exists(CACHE_FILE):
            os.remove(CACHE_FILE)

def main():
    player = MusicPlayer()
    
    if len(sys.argv) < 2:
        print("Usage: m <url|file|folder>")
        print("       m play <url|file|folder>")
        print("       m pause")
        print("       m next")
        print("       m prev")
        print("       m stop")
        print("       m vol [0-100]")
        print("       m info")
        print("")
        print("Shortcuts:")
        print("  m <url>    Play URL or folder")
        print("  m f       Toggle play/pause")
        print("  m n       Next track")
        print("  m p       Previous track")
        print("  m s       Stop")
        print("  m i       Show current track")
        return
        
    cmd = sys.argv[1]
    
    if cmd in ("play", "p") and len(sys.argv) > 2:
        player.play(sys.argv[2])
    elif cmd in ("pause", "f"):
        player.pause()
    elif cmd in ("next", "n"):
        player.next()
    elif cmd in ("prev", "pr"):
        player.prev()
    elif cmd in ("stop", "s"):
        player.stop()
    elif cmd in ("vol", "v"):
        player.vol(sys.argv[2] if len(sys.argv) > 2 else None)
    elif cmd in ("info", "i"):
        player.info()
    else:
        # Treat as play target
        player.play(cmd)

if __name__ == "__main__":
    main()