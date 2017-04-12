
--
-- Copyright (C) 2017 DBot
-- 
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
-- 
--     http://www.apache.org/licenses/LICENSE-2.0
-- 
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
-- 

import vgui, DMaps, table from _G

PANEL =
	Init: =>
		@buttons = {}
		@waypoints = vgui.Create('DButton', @)
		@options = vgui.Create('DButton', @)
		@waypoints\SetText('Waypoints')
		@options\SetText('Options')
		table.insert(@buttons, @waypoints)
		table.insert(@buttons, @options)
	
	DoSetup: (w = 0, h = 0, addH = 0) =>
		mw, mh = w / 4, 30
		@SetSize(mw, mh)
		@SetPos(w / 2 - mw / 2, h - mh + addH)
		step = mw / (#@buttons + 1)
		for i, button in pairs @buttons
			button\SetPos(step * i, 3)
			button\SetSize(step, mh - 6)

DMaps.PANEL_CONTROL_BUTTONS = PANEL
return PANEL