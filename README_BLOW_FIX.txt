Birthday Boy You — Blow Detection Fix

What changed:
- Default mic sensitivity is now 90%.
- Loudness is the primary blow signal; noise/voice analysis only adjusts it.
- Calibration ignores loud input so accidentally blowing during calibration no longer ruins the threshold.
- A strong close-mic air burst always produces some wind.
- Voice/yelling is weakened rather than completely rejected.
- Candle heat drains much faster once real wind is detected.
- "NO MIC SIGNAL" is displayed if Godot receives no microphone frames.
- SPACE still provides a deterministic test blow.

If you see NO MIC SIGNAL on macOS:
System Settings -> Privacy & Security -> Microphone
and enable microphone access for Godot.

Recommended test:
1. Start Birthday Mode.
2. Stay quiet for about 1 second.
3. Put your mouth about 10–25 cm from the Mac microphone.
4. Blow a steady "fuuuu" for 1–2 seconds.
5. Watch the Wind % meter. Around 20%+ should visibly bend and weaken flames.
