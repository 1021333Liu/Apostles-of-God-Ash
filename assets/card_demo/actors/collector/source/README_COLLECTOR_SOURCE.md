# Collector Fullbody Source Handoff

This folder is reserved for artist-provided source art. Do not place AI-generated placeholder Collector art here.

## Required P0 Source

Expected file:

```text
assets/card_demo/actors/collector/source/collector_fullbody_front.png
```

Requirements:

- Transparent PNG.
- Fullbody standing character, not bust portrait.
- Suggested long side: `1400px` or higher.
- The whole body, feet, robe hem, hands, and record tools must be visible.
- Character should face front or right-front and be suitable for standing inside the Silent Casket scene.
- Visual identity: doctor / researcher / archivist / reliquary caretaker.
- Required markers: silver-gray long robe or old medical coat, record papers, dirty silver metal clip, sample label, sealing wax, gloves, thin pen or similar recording tool.
- Palette: low saturation, cold white, dirty silver, gray-brown, old paper yellow; dark red only for wax or tiny sample marks.
- Forbidden: demon, wizard, merchant, cyberpunk scientist, modern lab computer, neon UI, high-saturation magic glow, copied composition from a specific painting.

## Deterministic Processing

After the artist source exists, run:

```powershell
python tools\process_collector_fullbody.py --update-manifest
```

The processor creates:

```text
assets/card_demo/actors/collector/collector_fullbody_idle_0.png
assets/card_demo/actors/collector/collector_fullbody_idle_1.png
assets/card_demo/actors/collector/collector_fullbody_idle_2.png
assets/card_demo/actors/collector/collector_fullbody_idle_3.png
assets/card_demo/actors/collector/collector_fullbody_speak_0.png
...
assets/card_demo/actors/collector/collector_fullbody_speak_5.png
```

Runtime frame contract:

- `768x768` transparent PNG.
- Feet anchor: `x=384, y=720`.
- Manifest actions: `fullbody_idle`, `fullbody_speak`.
- Anchor mode: `feet`.
- Suggested draw size: `320x420`.

If the source image is missing, the processor exits without generating fake frames.
