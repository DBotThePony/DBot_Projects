
-- Copyright (C) 2018 DBot

-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at

--     http://www.apache.org/licenses/LICENSE-2.0

-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

local LINK = DMySQL3.Connect('textscreens')

local extrarows = {}
local insertstr
local insertstrtab = {
	'gamemap',
	'x',
	'y',
	'z',
	'pitch',
	'yaw',
	'roll',
	'neverdraw',
	'alwaysdraw',
	'doubledraw',
	'screentext',
}

for i = 1, 16 do
	table.insert(extrarows, 'color' .. i .. ' INTEGER NOT NULL DEFAULT 13158600')
	table.insert(extrarows, 'align' .. i .. ' TINYINT NOT NULL DEFAULT 0')
	table.insert(extrarows, 'size' .. i .. ' TINYINT NOT NULL DEFAULT 0')
	table.insert(extrarows, 'font' .. i .. ' TINYINT NOT NULL DEFAULT 0')

	table.insert(insertstrtab, 'color' .. i)
	table.insert(insertstrtab, 'align' .. i)
	table.insert(insertstrtab, 'size' .. i)
	table.insert(insertstrtab, 'font' .. i)
end

insertstr = table.concat(insertstrtab, ',')

local dbDef = [[
CREATE TABLE IF NOT EXISTS dtextscreens (
	id INTEGER NOT NULL PRIMARY KEY ]] .. LINK:AI() .. [[,
	gamemap INTEGER NOT NULL,

	x FLOAT NOT NULL DEFAULT 0,
	y FLOAT NOT NULL DEFAULT 0,
	z FLOAT NOT NULL DEFAULT 0,

	pitch FLOAT NOT NULL DEFAULT 0,
	yaw FLOAT NOT NULL DEFAULT 0,
	roll FLOAT NOT NULL DEFAULT 0,
	neverdraw BOOLEAN NOT NULL DEFAULT 0,
	alwaysdraw BOOLEAN NOT NULL DEFAULT 0,
	doubledraw BOOLEAN NOT NULL DEFAULT 1,

	screentext TEXT NOT NULL DEFAULT '',

	]] .. table.concat(extrarows, ', ') .. [[
)
]]

LINK:Query(dbDef)

concommand.Add('dtextscreen_new', function(self, cmd, args)
	CAMI.PlayerHasAccess(self, 'dtextscreen_new', function(can, reason)
		if not can then
			DTextScreens.LMessagePlayer(self, 'message.textscreens.error.no_access')
			return
		end

		local id = tonumber(args[1])

		if not id then
			DTextScreens.LMessagePlayer(self, 'message.textscreens.error.none_provided')
			return
		end

		local ent = Entity(id)

		if not IsValid(ent) then
			DTextScreens.LMessagePlayer(self, 'message.textscreens.error.invalid')
			return
		end

		if ent:GetClass() ~= 'dbot_textscreen' then
			DTextScreens.LMessagePlayer(self, 'message.textscreens.error.not_a_textscreen')
			return
		end

		if ent:GetIsPersistent() then
			DTextScreens.LMessagePlayer(self, 'message.textscreens.error.already_present')
			return
		end

		local map = util.CRC(game.GetMap())
		local pos = ent:GetPos()
		local ang = ent:GetAngles()

		local text = ent:GetTextSlot1() .. ent:GetTextSlot2() .. ent:GetTextSlot3() .. ent:GetTextSlot4()

		local lines = {}

		table.insert(lines, SQLStr(map))

		local x, y, z = SQLStr(string.format('%.2f', pos.x)), SQLStr(string.format('%.2f', pos.y)), SQLStr(string.format('%.2f', pos.z))

		table.insert(lines, x)
		table.insert(lines, y)
		table.insert(lines, z)

		table.insert(lines, SQLStr(ang.p))
		table.insert(lines, SQLStr(ang.y))
		table.insert(lines, SQLStr(ang.r))

		table.insert(lines, SQLStr(ent:GetNeverDraw() and '1' or '0'))
		table.insert(lines, SQLStr(ent:GetAlwaysDraw() and '1' or '0'))
		table.insert(lines, SQLStr(ent:GetDoubleDraw() and '1' or '0'))
		table.insert(lines, SQLStr(text))

		for i = 1, 16 do
			table.insert(lines, SQLStr(ent['GetTextColor' .. i](ent)))
			table.insert(lines, SQLStr(ent['GetAlign' .. i](ent)))
			table.insert(lines, SQLStr(ent['GetTextSize' .. i](ent)))
			table.insert(lines, SQLStr(ent['GetFontID' .. i](ent)))
		end

		LINK:Query('INSERT INTO dtextscreens (' .. insertstr .. ') VALUES (' .. table.concat(lines, ', ') .. ')', function()
			LINK:Query(string.format('SELECT id FROM dtextscreens WHERE gamemap = %s AND x = %s AND y = %s AND z = %s', map, x, y, z), function(data)
				if not data or #data == 0 then
					DTextScreens.LMessagePlayer(self, 'message.textscreens.error.noid')
					return
				end

				local id = data[1].id

				local clone = ents.Create('dbot_textscreen')
				ent:CloneInto(clone)

				clone:SetPos(pos)
				clone:SetAngles(ang)

				clone:SetIsMovable(false)
				clone:SetIsPersistent(true)

				clone:Spawn()
				clone:Activate()

				ent:Remove()

				clone.DATABASE_ID = id

				DTextScreens.LMessagePlayer(self, 'message.textscreens.status.success_save')
			end, function(err)
				DTextScreens.LMessagePlayer(self, 'message.textscreens.error.sql', err)
				DTextScreens.LMessage(self, 'message.textscreens.error.sql', err)
			end)
		end, function(err)
			DTextScreens.LMessagePlayer(self, 'message.textscreens.error.sql', err)
			DTextScreens.LMessage(self, 'message.textscreens.error.sql', err)
		end)
	end)
end)

concommand.Add('dtextscreen_remove', function(self, cmd, args)
	CAMI.PlayerHasAccess(self, 'dtextscreen_remove', function(can, reason)
		if not can then
			DTextScreens.LMessagePlayer(self, 'message.textscreens.error.no_access')
			return
		end

		local id = tonumber(args[1])

		if not id then
			DTextScreens.LMessagePlayer(self, 'message.textscreens.error.none_provided')
			return
		end

		local ent = Entity(id)

		if not IsValid(ent) then
			DTextScreens.LMessagePlayer(self, 'message.textscreens.error.invalid')
			return
		end

		if ent:GetClass() ~= 'dbot_textscreen' then
			DTextScreens.LMessagePlayer(self, 'message.textscreens.error.not_a_textscreen')
			return
		end

		if not ent:GetIsPersistent() or not ent.DATABASE_ID then
			DTextScreens.LMessagePlayer(self, 'message.textscreens.error.not_present')
			return
		end

		LINK:Query('DELETE FROM dtextscreens WHERE id = ' .. ent.DATABASE_ID, function()
			ent:Remove()
			DTextScreens.LMessagePlayer(self, 'message.textscreens.status.success_remove')
		end, function(err)
			DTextScreens.LMessagePlayer(self, 'message.textscreens.error.sql', err)
			DTextScreens.LMessage(self, 'message.textscreens.error.sql', err)
		end)
	end)
end)

local IS_LOADING = false
local LoadTextscreens

concommand.Add('dtextscreen_reload', function(self, cmd, args)
	CAMI.PlayerHasAccess(self, 'dtextscreen_reload', function(can, reason)
		if not can then
			DTextScreens.LMessagePlayer(self, 'message.textscreens.error.no_access')
			return
		end

		if IS_LOADING then
			DTextScreens.LMessagePlayer(self, 'message.textscreens.error.already_loading')
			return
		end

		LoadTextscreens(function(err)
			if not err then
				DTextScreens.LMessagePlayer(self, 'message.textscreens.status.success_reload')
				DTextScreens.LMessage(self, 'message.textscreens.status.reloaded')
			else
				DTextScreens.LMessagePlayer(self, 'message.textscreens.error.sql', err)
				DTextScreens.LMessage('message.textscreens.error.sql', err)
				DTextScreens.LMessage(self, 'message.textscreens.status.reload_fail')
			end
		end)
	end)
end)

function LoadTextscreens(callback)
	if IS_LOADING then return end

	IS_LOADING = true

	local map = util.CRC(game.GetMap())

	for i, ent in ipairs(ents.GetAll()) do
		if ent:GetClass() == 'dbot_textscreen' and ent:GetIsPersistent() then
			ent:Remove()
		end
	end

	LINK:Query('SELECT * FROM dtextscreens WHERE gamemap = ' .. SQLStr(map), function(data)
		--xpcall(function()
		for i, row in ipairs(data) do
			local screen = ents.Create('dbot_textscreen')

			screen.DATABASE_ID = row.id:tonumber()

			screen:SetPos(Vector(row.x:tonumber(), row.y:tonumber(), row.z:tonumber()))
			screen:SetAngles(Angle(row.pitch:tonumber(), row.yaw:tonumber(), row.roll:tonumber()))

			screen:SetIsMovable(false)
			screen:SetIsPersistent(true)

			screen:SetAlwaysDraw(tobool(row.alwaysdraw))
			screen:SetNeverDraw(tobool(row.neverdraw))
			screen:SetDoubleDraw(tobool(row.doubledraw))

			for i = 1, 16 do
				table.insert(insertstrtab, 'color' .. i)
				table.insert(insertstrtab, 'align' .. i)
				table.insert(insertstrtab, 'size' .. i)
				table.insert(insertstrtab, 'font' .. i)

				screen['SetTextColor' .. i](screen, row['color' .. i]:tonumber())
				screen['SetAlign' .. i](screen, row['align' .. i]:tonumber())
				screen['SetTextSize' .. i](screen, row['size' .. i]:tonumber())
				screen['SetFontID' .. i](screen, row['font' .. i]:tonumber())
			end

			screen:SetTextSlot1(row.screentext:sub(1, 0xFFF))
			screen:SetTextSlot2(row.screentext:sub(0x1000, 0x1FFF))
			screen:SetTextSlot3(row.screentext:sub(0x2000, 0x2FFF))
			screen:SetTextSlot4(row.screentext:sub(0x3000, 0x3FFF))

			screen:Spawn()
			screen:Activate()
		end

		IS_LOADING = false
		DTextScreens.LMessage('message.textscreens.status.spawned', #data)
		if callback then callback() end
	--end, function(err) print(debug.traceback(err)) end)
	end, function(err)
		DTextScreens.LMessage('message.textscreens.error.sql', err)
		IS_LOADING = false
		if callback then callback(err) end
	end)
end

if ents.GetCount() > 20 then
	LoadTextscreens()
end

hook.Add('InitPostEntity', 'DTextScreens.PutScreens', LoadTextscreens)
