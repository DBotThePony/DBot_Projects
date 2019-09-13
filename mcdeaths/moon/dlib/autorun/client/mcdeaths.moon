
-- Copyright (C) 2019 DBotThePony

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

import net, DLib from _G
import i18n from DLib

color_npc = Color(200, 200, 200)

net.receive 'mcdeaths_npcdeath', ->
	point = net.ReadVector()
	text = net.ReadStringArray()

	rebuild = i18n.rebuildTable(text, color_npc, true)

	MsgC(color_npc, unpack(rebuild, 1, #rebuild))
	MsgC('\n')

net.receive 'mcdeaths_death', ->
	point = net.ReadVector()
	ply = net.ReadEntity()
	text = net.ReadStringArray()

	rebuild = i18n.rebuildTable(text, color_white, true)

	MsgC(color_white, unpack(rebuild, 1, #rebuild))
	MsgC('\n')

return
