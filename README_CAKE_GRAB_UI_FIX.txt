Birthday Boy You — Cake Grab + UI Fit Fix

Fixed:
- Cake pieces now form one complete round cake with no empty center.
- Each slice is a true wedge-shaped 3D piece, not boxes arranged in a ring.
- Cake picking no longer depends only on a tiny physics hitbox.
- Clicking near the visible center of a slice grabs it with a generous hit area.
- Held cake lifts slightly so it is obvious that it was grabbed.
- Release before eating -> the slice returns to its original position.
- Drag to the visible bottom-center eating area to take a bite.
- Clear 4-step cake controls are always visible during cake eating.
- The eating target is visibly marked on screen.
- UI safe sizing improved for smaller / different-aspect screens.
- Base canvas returned to 1280x720 with expand stretching to reduce clipping.
- Settings panel height reduced so it is less likely to be cut off.

Cake controls:
1. Click and HOLD a cake slice.
2. Drag while still holding the mouse button.
3. Move it to the bottom-center "bring it here" area.
4. Keep it there briefly to eat a bite.
5. Release elsewhere to put it back.

Install:
1. Close Godot.
2. Put BirthdayBoyYou_cakegrab_ui_fix.zip on Desktop.
3. Terminal:

   cd ~/Desktop
   cp -R BirthdayBoyYou BirthdayBoyYou_before_cakegrabfix
   unzip -o BirthdayBoyYou_cakegrab_ui_fix.zip -d BirthdayBoyYou
   open ~/Desktop/BirthdayBoyYou/project.godot
