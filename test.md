```mermaid
flowchart LR
    A[v-sekai-game] --> B(addons/)
    B --> VR/XR
    VR/XR --> addon0[**xr_vignette**<hr>Experimental camera tunnel shader to reduce motion sickness]
    VR/XR --> addon18[**sar1_mocap_manager**<hr>Motion capture reading/recording in a custom format]
    VR/XR --> addon19[**sar1_screenshot_manager**<hr>Utility to capture screenshots]
    VR/XR --> addon20[**sar1_vr_manager**<hr>Main VR Controller. Manages HMD settings, trackers, render tree.]
    addon20 --> dir0[**components**<hr>Lasso, Teleport, Hand Pose, Locomotion functions]
    VR/XR --> addon21[**input_manager**<hr>Input device setup for Joypad/Mouse]
    VR/XR --> addon13[**spatial_game_viewport_manager**<hr>Manages viewport size changes]
    VR/XR --> addon29["**flat_viewport**<hr>Control for handling offscreen rendering (from a VR device for example)"]
    B --> VRM
    VRM --> addon10[**vrm**<hr>Godot VRM Avatar implementation]
    VRM --> addon11[**Godot-MToon-Shader**<hr>Godot Toon shader for VRM Avatars]
    VRM --> addon1[**vsk_vrm_avatar_tool**<hr>VRM Avatar Converter]
    B --> Misc
    Misc --> addon2[**vsk_version**<hr>Version Strings]
    Misc --> addon8[**gd_util**<hr>Generic utility functions for 3d transforms, camera]
    Misc --> addon23[**math_util**<hr>Utility math functions]
    Misc --> addon12[**smoothing**<hr>Fixed timestep interpolation addon for framerate independent physics]
    Misc --> addon5[**splerger**<hr>Mesh splitting with 3d grid for Map culling or pre-upload transform]
    Misc --> addon22[**line_renderer**<hr>Experimental line render for 3d pen writing function]
    B --> UI
    UI --> addon3[**vsk_menu**<hr>Main title menus and in-game menus]
    UI --> addon28[**fade_manager**<hr>Controls full screen fading including in VR]
    UI --> addon31[**canvas_plane**<hr>Utility to position Godot control nodes in 3D space]
    UI --> addon7[**textureRectUrl**<hr>Image preview controls for UI item grids]
    UI --> addon24[**navigation_controller**<hr>Menu state controller for menu switching]
    UI --> addon15[**emote_theme**<hr>Font files and theme settings]
    B --> Audio
    Audio --> addon14[**kenney_ui_audio**<hr>UI sound sfx .wav library]
    Audio --> addon9[**godot_speech**<hr>Audio packets decoder/encoder]
    B --> addon16[**background_loader**<hr>Interface for resource load requests with whitelist]
    B --> addon17[**extended_kinematic_body**<hr>Improved CharacterBody3d with better tolerance for stairs/slopes]
    B --> Network
    Network --> addon25[**network_manager**<hr>Manages network settings, logic, physics, spawning commands...]
    Network --> addon26[**godot_uro**<hr>Uro API server interface to send requests for login, avatars, maps upload/download]
    B --> addon27[**godot_state_charts**<hr>Base class for Actor animation states]
    B --> addon32[**actor**<hr>Player actor state machine and camera controller]
    addon32 --> dir1["**states**<hr>Actor states(jump, fall...) for state machine"]
    B --> addon33[**vsk_importer_exporter**<hr>Avatar/scene import and export validation]
    B --> addon34[**vsk_editor**<hr>Editor plugin for uploading Maps/Avatars to Uro server]
    B --> addon38[**vsk_manager**<hr>Main game logic]
    addon38 --> dir5{**vsk_startup_manager.gd**<hr>Game Entrypoint}
    addon38 --> dir6[**outside_game_root_vr.tscn**<hr>Debug Menu scene]
    addon38 --> dir7[**vsk_asset_manager.gd**<hr>Manages http or local requests of assets]
    addon38 --> dir8[**xr_vignette/**<hr>test]
    B --> Entities
    Entities --> addon35[**vsk_avatar**<hr>Avatar definition, load/setup of bones, IK, hand poses]
    Entities --> addon4[**vsk_map**<hr>Class definitions for game Maps]
    Entities --> addon30[**entity_manager**<hr>Manages in-game entities and logic, physics, scene spawing and network coordination]
    Entities --> addon36[**vsk_entities**<hr>Game entities initialization. Contains player avatar main scene.]
    addon36 --> dir2[**vsk_player_old.tscn**<hr>Current player Avatar entity instance]
    addon36 --> dir3[**vsk_player.tscn**<hr>Unused experimental player entity with a godot head and floating hands.]
    addon36 --> dir4[**xr_vignette/**<hr>test]
    Entities --> addon6[**state_machine**<hr>Base class for state machines]
    B --> addon39[**xr_vignette/**<hr>test]
    B --> addon40[**xr_vignette/**<hr>test]
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
