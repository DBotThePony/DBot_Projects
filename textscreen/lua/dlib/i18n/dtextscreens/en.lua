
-- Copyright (C) 2018-2019 DBot

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
-- of the Software, and to permit persons to whom the Software is furnished to do so,
-- subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all copies
-- or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
-- INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
-- PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
-- FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
-- DEALINGS IN THE SOFTWARE.


gui.tool.textscreens.font_all = 'Set all lines font to'
gui.tool.textscreens.font = 'Text font'
gui.tool.textscreens.reset = 'Reset all values'
gui.tool.textscreens.reset_this = 'Reset these values'
gui.tool.textscreens.reset_this_under = 'Reset this and next lines'
gui.tool.textscreens.spoiler = 'Text line %i'
gui.tool.textscreens.text = 'Text'
gui.tool.textscreens.newline = 'Put this text on a new line'
gui.tool.textscreens.fontsize = 'Font size'
gui.tool.textscreens.shadow = 'Make a shadow'
gui.tool.textscreens.overall_size = 'Overall size'
gui.tool.textscreens.rotate = 'Rotation'

gui.tool.textscreens.movable = 'Make screen be gravity affected'
gui.tool.textscreens.doubledraw = 'DoubleDraw (draw both sides)'
gui.tool.textscreens.alwaysdraw = 'Always draw model'
gui.tool.textscreens.neverdraw = 'Never draw model'

gui.tool.textscreens.align.line = 'Align per line (H)'
gui.tool.textscreens.align.row = 'Align per row (V)'

gui.tool.textscreens.align.left = 'Left'
gui.tool.textscreens.align.right = 'Right'
gui.tool.textscreens.align.center = 'Center'
gui.tool.textscreens.align.top = 'Top'
gui.tool.textscreens.align.bottom = 'Bottom'

message.textscreens.error.no_access = 'No access to that feature!'
message.textscreens.error.none_provided = 'Invalid ID!'
message.textscreens.error.invalid = 'Invalid entity!'
message.textscreens.error.not_a_textscreen = 'Target entity is not a text screen'
message.textscreens.error.already_present = 'Target textscreen is already present in database'
message.textscreens.error.already_loading = 'Textscreens are already being loaded!'
message.textscreens.error.not_present = 'Target textscreen is not present in database'
message.textscreens.error.unknown = 'Unknown error'
message.textscreens.error.noid = 'Text screen were stored in database, but did not return valid ID'
message.textscreens.error.sql = 'SQL Execution error:\n%s'

message.textscreens.status.success_save = 'Successfully added textscreen to database'
message.textscreens.status.success_remove = 'Successfully removed textscreen from database'
message.textscreens.status.success_reload = 'Successfully reloaded textscreens from database'
message.textscreens.status.reloaded = ' reloaded textscreens from database'
message.textscreens.status.reload_fail = ' failed to reload textscreens from database'
message.textscreens.status.spawned = 'Spawned present textscreens from database (if any). Total spawned: %i'

gui.property.dtextscreens.new = 'Make persistent textscreen'
gui.property.dtextscreens.remove = 'Remove persistent textscreen'
gui.property.dtextscreens.clone = 'Clone this textscreen'

gui.tool.dtextscreen.name = 'Textscreens placer'
gui.tool.dtextscreen.desc = 'Allows you to do place, modify and copy operations over textscreens'
gui.tool.dtextscreen.left = 'Left click to place/update textscreens'
gui.tool.dtextscreen.right = 'Right click to copy existing textscreen settings'

gui.undone.dtextscreen = 'Undone DTextScreen'
