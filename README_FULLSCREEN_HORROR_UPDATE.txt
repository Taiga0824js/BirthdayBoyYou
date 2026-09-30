Birthday Boy You - Fullscreen / BGM / Subtle Horror Update

FIXES
- Title and menu now use ONE continuous BGM player.
- The title song does not restart when the menu appears.
- There is no second menu BGM playing underneath it.
- menu.mp3 is no longer needed.
- Fullscreen is now the startup default.
- Removed the old 1280x720 window override.
- Internal design remains 1280x720, but fullscreen scales it to the display.
- 16:9 presentation now uses KEEP aspect, so UI/3D should not be cropped on
  displays such as 16:10 Mac screens.
- Camera moved slightly back to give side decorations more room.
- Menu and Settings UI made slightly smaller for safer margins.

SUBTLE HORROR
No jumpscares were added.
Instead:
- Rare, very soft dark-light flicker.
- Occasionally a nearly black extra "guest" appears at the far edge of the room
  for less than a second.
- Horror effects are disabled during Candle Challenge.
This is intended to feel slightly uncanny rather than turn the game into horror.

CUSTOM AUDIO
Place your files in:
    assets/audio/custom/

Required/recommended names:
    title.mp3
    candle_out.wav
    applause.wav
    eat.wav

MP3 / WAV / OGG work for the SE files.

IMPORTANT WHEN TESTING INSIDE GODOT 4.7
If Godot is using its embedded Game view, the editor can still show the project
inside a fixed editor panel even though the actual game is configured fullscreen.
In the Game panel dropdown, disable "Embed Game on Next Play" to test the real
fullscreen window.

Install:
    cd ~/Desktop
    cp -R BirthdayBoyYou BirthdayBoyYou_before_fullscreen_horror
    unzip -o BirthdayBoyYou_fullscreen_horror_update.zip -d BirthdayBoyYou
    open ~/Desktop/BirthdayBoyYou/project.godot
