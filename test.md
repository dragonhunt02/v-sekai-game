```mermaid
flowchart LR
    A[v-sekai-game] --> B(addons/)
    B --> addon0[**xr_vignette**<hr>Experimental camera tunnel shader to reduce motion sickness]
    B --> addon4[**vsk_map**<hr>Class definitions for game Maps]
    B --> addon5[**splerger**<hr>Mesh splitting with 3d grid for Map culling or pre-upload transform]
    B --> addon6[**state_machine**<hr>Base class for state machines]
    B --> addon8[**gd_util**<hr>Generic utility functions for 3d transforms, camera]
    B --> VRM
    VRM --> addon10[**vrm**<hr>Godot VRM Avatar implementation]
    VRM --> addon11[**Godot-MToon-Shader**<hr>Godot Toon shader for VRM Avatars]
    VRM --> addon1[**vsk_vrm_avatar_tool**<hr>VRM Avatar Converter]
    B --> Misc
    Misc --> addon2[**vsk_version**<hr>Version Strings]
    B --> UI
    UI --> addon3[**vsk_menu**<hr>Main title menus and in-game menus]
    UI --> addon7[**textureRectUrl**<hr>Image previews for UI item grids]
    B --> Audio
    Audio --> addon14[**kenney_ui_audio**<hr>UI sound sfx .wav library]
    Audio --> addon9[**godot_speech**<hr>Audio packets decoder/encoder]
    B --> addon12[**smoothing**<hr>Fixed timestep interpolation addon for framerate independent physics]
    B --> addon13[**spatial_game_viewport_manager**<hr>Manages viewport size changes]
    B --> addon15[**xr_vignette/**<hr>test]
    B --> addon15[**xr_vignette/**<hr>test]
    B --> addon15[**xr_vignette/**<hr>test]
    B --> addon15[**xr_vignette/**<hr>test]
    B --> addon15[**xr_vignette/**<hr>test]
    B --> addon15[**xr_vignette/**<hr>test]
    B --> addon15[**xr_vignette/**<hr>test]
```

```mermaid
mindmap
    (v-sekai-game)
        (addons/)
        (**vsk_vrm_avatar_tool**</br>VRM Avatar Converter)
```




```mermaid
flowchart TB
  A[<a href='https://github.com/dragonhunt02/v-sekai-game/blob/docs/codebase.md#test'>works</a>]
```
    subgraph one
        C --> D[Keep]
    end
    C --> E[Edit Definition]
    E --> B
    D --> F[Save Image and Code]
    F --> B

<a id='test'>works</a>
