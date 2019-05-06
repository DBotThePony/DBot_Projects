
-- Copyright (C) 2018-2019 DBotThePony

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

gui.toybox.tab = 'DToyBox'
gui.toybox.tab_tip = 'Used to hotload any addon from the workshop'

gui.toybox.frame = 'DToyBox addon browsing'
gui.toybox.controls.open_full = 'Open in new window (has html keyboard focus fixed)'
gui.toybox.controls.button.not_avaliable = 'No access!'
gui.toybox.controls.button.ready = 'Load this addon!'
gui.toybox.controls.button.ready_collection = 'Load this collection!'
gui.toybox.controls.button.browse = 'Open an addon page...'
gui.toybox.controls.button.busy = '< ... >'
gui.toybox.controls.button.error = 'ERROR'
gui.toybox.controls.button.enabled = 'Addon is already loaded!'
gui.toybox.controls.button.ready_tooltip = 'Click here to install selected addon!\nIf you opened up a page of banned addon, YOU CAN still download and use it!\nExample: Neurotec Base Part 1: it got banned but going on its page will still allow you to load it\naltrough steam would say "nothing here"\n\nAlso notice that this is not a simple workaround - before loading banned addons consider doing so, because they got banned for a reason'
gui.toybox.controls.button.browse_tooltip = 'Open any workshop item page to load an addon! Collections are supported too!'
gui.toybox.controls.button.shared_parts = 'INSTALL SHARED PARTS'
gui.toybox.notify.text = 'Remember that not all (but very close to all) addons can be actually hotloaded!\n(due to how they work)\n\nAlso, if you loaded a weapon or an entity (or a vehicle), don\'t forget to spawnmenu_reload in your console!\nThis is not done automatically since it is very perfomance intence (unless you dont have much addons installed)\n\n--- WARNING ---\nIF ADDON REQUIRES A BASE, INSTALL IT FIRST, OTHERWISE YOU WOULD FAIL SO BAD\nYOU WERE WARNED'
gui.toybox.notify.header = 'Notice about hotloading addons'
gui.toybox.notify.button = 'Got it!'

message.toybox.missing_access = 'No access!'
