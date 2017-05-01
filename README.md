
# DMaps

After three weeks in developement, hopefully it worths the **weight**
## Welcome to DMaps!
An addon adding world-map, a minimap, with waypoints, as well custom server-side waypoints, and much, much more, such as great API to interact with maps!

An addon, that adds a interactive map in Garry's Mod!

DMaps is influenced by [GMaps](https://www.gmodstore.com/scripts/view/2375), [VoxelMap](https://minecraft.curseforge.com/projects/voxelmap), [Terraria](http://store.steampowered.com/app/105600/Terraria/) map and [Watch_Dogs_2](http://store.steampowered.com/app/447040/Watch_Dogs_2/) map

## Features
 * Map display with zoom level and clip levels (known as "Cave Mode" in [VoxelMap](https://minecraft.curseforge.com/projects/voxelmap))
 * Clientside waypoints
 * Serverside waypoints (simple ("persistent"), Per usergroup, Per CAMI usergroup, Per Team)
 * Simple navigation system using [Navmesh](url=https://developer.valvesoftware.com/wiki/Navigation_Meshes) and [A* Search Algorithm](https://en.wikipedia.org/wiki/A*_search_algorithm) (can be disabled by server owner)
 * Players display on map (configurable, can be disabled by server owner)
 * NPC display on map (configurable, can be disabled by server owner)
 * Vehicles display on map (configurable, can be disabled by server owner)
 * Events (points) display on map (such as arrests, deaths, ...) (configurable, can be disabled by server owner)
 * Minimap mode

## [Apache software foundation License 2.0](LICENSE) ([web version](https://www.apache.org/licenses/LICENSE-2.0))

# Thanks
 * [Leafo](https://github.com/leafo) for his awesome [Moonscript](http://moonscript.org/)!
 * [FatCow](http://fatcow.com) for awesome icons!


# Serverside console variables

```
sv_dmaps_arrest_duration                 : 5        // Player arrest event pointer live time in minutes
sv_dmaps_arrest_enable                   : 1        // Enable DarkRP arrest events display
sv_dmaps_deathpoints                     : 1        // Enable death points (players/NPCs)
sv_dmaps_deathpoints_duration            : 15       // Player death point live time in minutes
sv_dmaps_deathpoints_npc                 : 1        // Enable NPCs death points
sv_dmaps_deathpoints_player              : 1        // Enable Players death points
sv_dmaps_draw_players_armor              : 1        // Draw players armor on map
sv_dmaps_draw_players_health             : 1        // Draw players health on map
sv_dmaps_draw_players_info               : 1        // Draw players infos on map
sv_dmaps_draw_players_team               : 1        // Draw players teams on map
sv_dmaps_entities                        : 1        // Enable map entities display
sv_dmaps_nav_enable                      : 1        // Enable navigation support (if map has nav file)
sv_dmaps_npc_death_duration              : 1        // NPC death point live time in minutes
sv_dmaps_npcs                            : 1        // Enable map NPCs display
sv_dmaps_players                         : 1        // Enable player map arrows
sv_dmaps_vehicles                        : 1        // Enable map vehicles display
sv_dmaps_vehicles_driven                 : 3000     // Driven vehicle map track range
sv_dmaps_vehicles_undriven               : 512      // Undriven vehicle map track range
```

# Clientside console variables

```
cl_dmaps_color_arrows_button_b           : 230       // Arrows (joystick) middle button 'Blue' channel color
cl_dmaps_color_arrows_button_g           : 230       // Arrows (joystick) middle button 'Green' channel color
cl_dmaps_color_arrows_button_r           : 230       // Arrows (joystick) middle button 'Red' channel color
cl_dmaps_color_arrows_inner_b            : 170       // Arrows (joystick) inner 'Blue' channel color
cl_dmaps_color_arrows_inner_g            : 170       // Arrows (joystick) inner 'Green' channel color
cl_dmaps_color_arrows_inner_r            : 170       // Arrows (joystick) inner 'Red' channel color
cl_dmaps_color_arrows_outer_b            : 190       // Arrows (joystick) outer 'Blue' channel color
cl_dmaps_color_arrows_outer_g            : 190       // Arrows (joystick) outer 'Green' channel color
cl_dmaps_color_arrows_outer_r            : 190       // Arrows (joystick) outer 'Red' channel color
cl_dmaps_color_clip_background_b         : 40        // Clip control background 'Blue' channel color
cl_dmaps_color_clip_background_g         : 40        // Clip control background 'Green' channel color
cl_dmaps_color_clip_background_r         : 40        // Clip control background 'Red' channel color
cl_dmaps_color_clip_big_b                : 170       // Clip control 'Too big' 'Blue' channel color
cl_dmaps_color_clip_big_g                : 80        // Clip control 'Too big' 'Green' channel color
cl_dmaps_color_clip_big_r                : 80        // Clip control 'Too big' 'Red' channel color
cl_dmaps_color_clip_locked_b             : 230       // Clip control 'Locked' 'Blue' channel color
cl_dmaps_color_clip_locked_g             : 230       // Clip control 'Locked' 'Green' channel color
cl_dmaps_color_clip_locked_r             : 230       // Clip control 'Locked' 'Red' channel color
cl_dmaps_color_clip_unlocked_b           : 170       // Clip control 'Unlocked' 'Blue' channel color
cl_dmaps_color_clip_unlocked_g           : 170       // Clip control 'Unlocked' 'Green' channel color
cl_dmaps_color_clip_unlocked_r           : 170       // Clip control 'Unlocked' 'Red' channel color
cl_dmaps_color_color_north_b             : 0         // Compass north part 'Blue' channel color
cl_dmaps_color_color_north_g             : 0         // Compass north part 'Green' channel color
cl_dmaps_color_color_north_r             : 255       // Compass north part 'Red' channel color
cl_dmaps_color_color_south_b             : 230       // Compass south part 'Blue' channel color
cl_dmaps_color_color_south_g             : 230       // Compass south part 'Green' channel color
cl_dmaps_color_color_south_r             : 230       // Compass south part 'Red' channel color
cl_dmaps_color_compass_inner_b           : 200       // Compass inner 'Blue' channel color
cl_dmaps_color_compass_inner_g           : 200       // Compass inner 'Green' channel color
cl_dmaps_color_compass_inner_r           : 200       // Compass inner 'Red' channel color
cl_dmaps_color_compass_outer_b           : 180       // Compass outer 'Blue' channel color
cl_dmaps_color_compass_outer_g           : 70        // Compass outer 'Green' channel color
cl_dmaps_color_compass_outer_r           : 40        // Compass outer 'Red' channel color
cl_dmaps_color_light_b                   : 230       // Map hightlight (bottom light) color 'Blue' channel color
cl_dmaps_color_light_g                   : 230       // Map hightlight (bottom light) color 'Green' channel color
cl_dmaps_color_light_r                   : 230       // Map hightlight (bottom light) color 'Red' channel color
cl_dmaps_color_local_player_b            : 200       // Local player arrow 'Blue' channel color
cl_dmaps_color_local_player_g            : 80        // Local player arrow 'Green' channel color
cl_dmaps_color_local_player_r            : 80        // Local player arrow 'Red' channel color
cl_dmaps_color_minimap_border_b          : 160       // Minimap border color 'Blue' channel color
cl_dmaps_color_minimap_border_g          : 160       // Minimap border color 'Green' channel color
cl_dmaps_color_minimap_border_r          : 160       // Minimap border color 'Red' channel color
cl_dmaps_color_nav_arrow_b               : 217       // Navigation arrows color 'Blue' channel color
cl_dmaps_color_nav_arrow_g               : 209       // Navigation arrows color 'Green' channel color
cl_dmaps_color_nav_arrow_r               : 34        // Navigation arrows color 'Red' channel color
cl_dmaps_color_nav_target_b              : 255       // Navigation target point color 'Blue' channel color
cl_dmaps_color_nav_target_g              : 255       // Navigation target point color 'Green' channel color
cl_dmaps_color_nav_target_r              : 255       // Navigation target point color 'Red' channel color
cl_dmaps_color_remember_death_b          : 255       // Latest death point color 'Blue' channel color
cl_dmaps_color_remember_death_g          : 255       // Latest death point color 'Green' channel color
cl_dmaps_color_remember_death_r          : 255       // Latest death point color 'Red' channel color
cl_dmaps_color_zoom_background_b         : 40        // Zoom control background 'Blue' channel color
cl_dmaps_color_zoom_background_g         : 40        // Zoom control background 'Green' channel color
cl_dmaps_color_zoom_background_r         : 40        // Zoom control background 'Red' channel color
cl_dmaps_color_zoom_big_b                : 230       // Zoom control 'Too big' 'Blue' channel color
cl_dmaps_color_zoom_big_g                : 230       // Zoom control 'Too big' 'Green' channel color
cl_dmaps_color_zoom_big_r                : 230       // Zoom control 'Too big' 'Red' channel color
cl_dmaps_color_zoom_locked_b             : 230       // Zoom control 'Locked' 'Blue' channel color
cl_dmaps_color_zoom_locked_g             : 230       // Zoom control 'Locked' 'Green' channel color
cl_dmaps_color_zoom_locked_r             : 230       // Zoom control 'Locked' 'Red' channel color
cl_dmaps_color_zoom_unlocked_b           : 170       // Zoom control 'Unlocked' 'Blue' channel color
cl_dmaps_color_zoom_unlocked_g           : 170       // Zoom control 'Unlocked' 'Green' channel color
cl_dmaps_color_zoom_unlocked_r           : 170       // Zoom control 'Unlocked' 'Red' channel color
cl_dmaps_draw_arrests                    : 1         // Draw arrest events on map
cl_dmaps_draw_beam                       : 1         // Draw waypoint beam
cl_dmaps_draw_deathpoints                : 1         // Draw deathpoints on map
cl_dmaps_draw_deathpoints_npc            : 1         // Draw NPCs deathpoints on map
cl_dmaps_draw_deathpoints_player         : 1         // Draw player deathpoints on map
cl_dmaps_draw_dist                       : 1         // Draw distance under waypoint name
cl_dmaps_draw_players                    : 1         // Draw players on map
cl_dmaps_draw_players_armor              : 1         // Draw players armor on map
cl_dmaps_draw_players_health             : 1         // Draw players health on map
cl_dmaps_draw_players_hpbar              : 1         // Draw players HP bars on map
cl_dmaps_draw_players_info               : 1         // Draw players infos on map
cl_dmaps_draw_players_team               : 1         // Draw players teams on map
cl_dmaps_draw_waypoints                  : 1         // Draw waypoints in world
cl_dmaps_entities                        : 1         // Draw ANY entities on map
cl_dmaps_minimap_dynamic                 : 1         // Is minimap dynamic in size
cl_dmaps_minimap_dynamic_max             : 5         // Maximal dynamic size
cl_dmaps_minimap_dynamic_min             : 1         // Minimap dynamic size
cl_dmaps_minimap_dynamic_mult            : 1         // Minimap dynamic speed multiplier
cl_dmaps_minimap_pos_x                   : 98        // Minimap % position of X
cl_dmaps_minimap_pos_y                   : 35        // Maximal % position of Y
cl_dmaps_minimap_size                    : 25        // Size in percents of minimap
cl_dmaps_minimap_zoom                    : 1000      // Minimal 'minimap mode' zoom
cl_dmaps_nav_line_dist                   : 1000      // How far navigation path should draw
cl_dmaps_npcs                            : 1         // Enable map NPCs display
cl_dmaps_remember_death                  : 1         // Remember last death point
cl_dmaps_smooth_animations               : 1         // Use smooth map animations
cl_dmaps_smooth_animations_amv           : 1         // Use smooth map MOVING JOYSTICK animation
cl_dmaps_smooth_animations_bclip         : 1         // Use smooth map Clip BAR animation
cl_dmaps_smooth_animations_bzoom         : 1         // Use smooth map ZOOM BAR animation
cl_dmaps_smooth_animations_mv            : 1         // Use smooth map moving animation
cl_dmaps_smooth_animations_zoom          : 1         // Use smooth map zoom animation
cl_dmaps_vehicles                        : 1         // Enable map vehicles display
cl_dmaps_wasd_ctrl                       : 0         // Sensivity of ctrl button on map
cl_dmaps_wasd_shift                      : 2         // Sensivity of shift button on map
cl_dmaps_wasd_speed                      : 850       // Sensivity of WASD buttons on map
```

# Screenshots

![Main window](https://dbot.serealia.ca/sharex/2017/04/cc8801c940_2017-04-30_12-36-04.png)

![Clientside waypoints](https://dbot.serealia.ca/sharex/2017/04/2739c480b3_2017-04-21_18-22-16.png)

![Waypoint edit menu](https://dbot.serealia.ca/sharex/2017/04/07afda3973_2017-04-21_18-22-39.png)
![CAMI serverside waypoint edit menu](https://dbot.serealia.ca/sharex/2017/04/86ebd4c912_2017-04-21_18-23-07.png)
![Icons](https://dbot.serealia.ca/sharex/2017/04/2488d1e154_2017-04-21_18-23-33.png)

![Smart in-world waypoint beam (configurable)](https://dbot.serealia.ca/sharex/2017/04/b5a8730c4c_2017-04-21_18-24-07.png)

![Navigation pathway display on map](https://dbot.serealia.ca/sharex/2017/04/a880ec3398_2017-04-30_12-37-03.png)

![Minimap mode](https://dbot.serealia.ca/sharex/2017/04/3e86d60eb5_2017-04-30_12-37-15.png)

![NPCs Display](https://dbot.serealia.ca/sharex/2017/04/4f59fcebe0_2017-04-30_12-38-12.png)

![Creating a waypoint #2](https://dbot.serealia.ca/sharex/2017/04/539f5e31aa_2017-04-30_12-39-34.png)

![Context menu](https://dbot.serealia.ca/sharex/2017/04/0edf581821_2017-04-30_12-39-43.png)