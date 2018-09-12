
-- Copyright (C) 2016-2018 DBot

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


DLib.RegisterAddonName('Bonus Ducks!')

local DockOMetrValue = 0
local DockOMetrValue_Server = 0

sql.Query('CREATE TABLE IF NOT EXISTS dbot_duckometr (cval integer not null)')
local select = sql.Query('SELECT * FROM dbot_duckometr')
DockOMetrValue = select and select[1] and select[1].cval or 0

concommand.Add('cl_duck_reset', function(ply, cmd, args)
	DockOMetrValue = 0
	sql.Query('DELETE FROM dbot_duckometr')
	print('Duck count reseted clientside!')
end)

surface.CreateFont('DBot_DuckOMeter', {
	font = 'Roboto',
	size = 18,
	weight = 500,
	extended = true,
})

local DuckDisplayTimer = 0

hook.Add('HUDPaint', 'DBot_DuckOMeter', function()
	if DuckDisplayTimer < CurTimeL() then return end
	local fade = (DuckDisplayTimer - CurTimeL()) / 4
	local x, y = ScrWL() - 200, ScrHL() / 2 + 100
	draw.DrawText(DLib.i18n.localize('gui.ducks.collected', DockOMetrValue, DockOMetrValue_Server), 'DBot_DuckOMeter', x, y, Color(255, 255, 255, fade * 255))
end)

net.Receive('DBot_DuckOMeter', function()
	DockOMetrValue = DockOMetrValue + 1
	DockOMetrValue_Server = net.ReadUInt(16)
	sql.Query('DELETE FROM dbot_duckometr')
	sql.Query('INSERT INTO dbot_duckometr (cval) VALUES (' .. DockOMetrValue .. ')')
	DuckDisplayTimer = CurTimeL() + 4
end)