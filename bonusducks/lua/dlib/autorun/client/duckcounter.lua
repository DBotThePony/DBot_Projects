
-- Copyright (C) 2016-2018 DBot

-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at

--     http://www.apache.org/licenses/LICENSE-2.0

-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

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