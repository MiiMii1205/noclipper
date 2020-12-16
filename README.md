# No Clipper # 

A pleasant, simple and fast NoClip script for [FiveM](https://fivem.net).

## Setup ##

Just clone this repo to your ressource folder of your [FiveM](https://fivem.net) server. You might also need to edit your server.cfg to auto load the resource.

Remember that this resource doesn't do any permission management. By default, it allows **EVERY** player to no clip.

To change this, you can set the `ENABLE_TOGGLE_NO_CLIP` (line 15) value in the `Scripts/noclipt.lua` file.

You can then use the exported `ToggleNoClipMode` in any other ressources, granted that your server loads No Cipper first.

## Controls ##

The controls are intuitive, and works just like your typical GTA controls.

| Input                                 | Controls                  |
|---------------------------------------|---------------------------|
| "Next Radio Station" (<kbd>></kbd>)   |  Enable / Disable NoClip  |
| <kbd>WASD</kbd> / Left Stick          |  Move / Strafe            |
| Mouse / Right Stick                   |  Turn                     |
| <kbd>Shift-r</kbd> / `A`              |  Go faster (Hold)         |
| <kbd>Q</kbd>                          |  Move Up                  |
| <kbd>E</kbd>                          |  Move Down                |

## Exports ##

The resource also exports a `ToggleNoClipMode` function that can be called to toggle NoClip from another resource.

