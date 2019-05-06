
--
-- Copyright (C) 2017-2019 DBotThePony
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

-- I know there is DProgress, but i dont want it

import vgui, Color, surface, DMaps, math from _G
import SetDrawColor, DrawRect from surface
import DeltaColor from DMaps

PANEL =
	Init: =>
		@colorThinking = Color(146, 176, 172)
		@colorFirst = Color(233, 98, 40)
		@colorFinal = Color(132, 242, 75)
		@background = Color(220, 220, 220)
		@SetSize(200, 20)
		@thinking = true
		@thinkAction = true
		@currentPos = 0
		@thinkSize = 15
		@percent = 0
	InvertColors: =>
		col1, col2 = @colorFirst, @colorFinal
		@colorFinal = col1
		@colorFirst = col2

	SetThinkSize: (val = 15) => @thinkSize = val
	GetThinkSize: => @thinkSize
	ThinkSize: => @thinkSize
	SetIsThinking: (val = true) => @thinking = val
	IsThinking: => @thinking
	GetIsThinking: => @thinking

	GetPercent: => @percent
	SetPercent: (val = 0) =>
		@percent = math.Clamp(val, 0, 1)
		@SetIsThinking(false)
	SetThinkingColor: (col1 = Color(146, 176, 172)) => @colorThinking = col1
	SetColor: (col1 = Color(253, 196, 163), col2 = col1) =>
		@colorFinal = col2
		@colorFirst = col1
	Paint: (w = 200, h = 20) =>
		SetDrawColor(@background)
		DrawRect(0, 0, w, h)
		if @thinking
			@currentPos += FrameTime() * w / 2 if @thinkAction
			@currentPos -= FrameTime() * w / 2 if not @thinkAction
			@thinkAction = not @thinkAction if @currentPos < 0 or @currentPos > w - @thinkSize
			SetDrawColor(@colorThinking)
			DrawRect(@currentPos, 0, @thinkSize, h)
		else
			col = DeltaColor(@colorFinal, @colorFirst, @percent)
			SetDrawColor(col)
			DrawRect(0, 0, w * @percent, h)
vgui.Register('DMapProgressBar', PANEL, 'EditablePanel')
return PANEL
