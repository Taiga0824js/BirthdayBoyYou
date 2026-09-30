Birthday Boy You — Reliable Cake Grab Fix

Why the previous version could still fail:
- Cake grabbing was handled in _unhandled_input, so full-screen UI Controls could consume the click before the cake logic saw it.
- Picking still depended too much on projected points / hit regions.

This version:
- Uses _input so cake clicks are received before GUI controls swallow them.
- All cake-eating overlays ignore mouse input.
- Clicking the visible cake intersects the mouse ray with the cake plane.
- The exact cake wedge is selected mathematically by its angle.
- A large screen-space fallback remains.
- Grab radius is much more forgiving.
- A grabbed slice visibly lifts and grows slightly.
- Releasing early returns it to the plate.
- Instructions now explicitly say LEFT-CLICK AND HOLD.

Install:
1. Close Godot.
2. Put BirthdayBoyYou_cakegrab_reliable.zip on Desktop.
3. Run:

   cd ~/Desktop
   cp -R BirthdayBoyYou BirthdayBoyYou_before_reliable_grab
   unzip -o BirthdayBoyYou_cakegrab_reliable.zip -d BirthdayBoyYou
   open ~/Desktop/BirthdayBoyYou/project.godot

Cake controls:
- Put the mouse over the visible cake.
- HOLD the left mouse button.
- The slice should immediately lift.
- Without releasing, drag to the bottom-center target.
