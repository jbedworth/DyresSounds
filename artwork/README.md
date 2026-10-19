# Dyre's Sounds logo

Original vector artwork: a pair of beamed gold notes glowing with warm light,
between segmented arcs of sound that fade outward, on a rich dark-brown
background. It shares its frame and colors with the other Dyre's logos (Dyre's
Shields Up, Mage Tools Forever, Warlock Tools Forever). The design has no font
or external-image dependencies.

- `dyres-sounds-logo.svg`: editable, resolution-independent source.
- `dyres-sounds-logo.png`: 1024 x 1024 PNG master.
- `dyres-sounds-logo-512.png`: 512 x 512 PNG for square project images.

The PNGs are rendered from the SVG with headless Chrome, for example:

```sh
chrome --headless=new --hide-scrollbars --window-size=1024,1024 --force-device-scale-factor=0.5 --screenshot=dyres-sounds-logo-512.png dyres-sounds-logo.svg
```

Use these files for project pages and distribution branding. Keep this
directory out of the runtime release ZIP; the TOC uses a built-in client icon
(INV_Misc_Bell_01).
