Birthday Boy You — Microphone + Display Update

Main changes:
- Microphone input now uses Godot 4.7's direct AudioServer input API.
- Settings now includes a selectable input microphone.
- Input list includes Default plus detected microphones.
- Switching microphone restarts the input stream and recalibrates.
- Refresh microphones button added.
- Selected microphone is saved.
- The game now launches maximized instead of in a small window.
- Fullscreen toggle added to Settings and saved.
- Internal design resolution raised to 1600x900.
- Fixed the previous microphone update flow that could fail to return correctly when no frames were available.

macOS:
If microphones are listed but the level still never moves:
System Settings -> Privacy & Security -> Microphone -> enable Godot.

Install:
1. Close Godot.
2. Put BirthdayBoyYou_micselect_large.zip on Desktop.
3. Run:

   cd ~/Desktop
   cp -R BirthdayBoyYou BirthdayBoyYou_before_micselect
   unzip -o BirthdayBoyYou_micselect_large.zip -d BirthdayBoyYou
   open ~/Desktop/BirthdayBoyYou/project.godot

Test:
Settings -> Microphone -> choose the actual microphone -> Test microphone.
