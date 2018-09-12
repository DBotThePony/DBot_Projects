
--[[
Copyright (C) 2016-2018 DBot


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

]]

ULXPP.Properties = ULXPP.Properties or {}

function ULXPP.AddProperty(class, menuopen)
	ULXPP.Properties[class] = {obj = ULXPP.GetCommand(class), menuopen = menuopen}
end

local Property = {
	MenuLabel = 'ULX',
	Order = 0,
	Filter = function(self, ent, ply)
		return ent:IsPlayer()
	end,

	MenuOpen = function(self, menu, ent, tr)
		local ply = LocalPlayer()
		local hit = false

		local sub = menu:AddSubMenu()
		local nick = ent:Nick()

		for k, v in pairs(ULXPP.Properties) do
			local access = ULib.ucl.query(ply, 'ulx ' .. k)
			if not access then continue end
			hit = true
			local menu2 = sub:AddOption(k, function()
				RunConsoleCommand('ulx', k, nick)
			end)

			if v.obj then
				menu2:SetTooltip(v.obj:getUsage(ply))
			end

			menu2.command = k
			menu2.nick = nick

			if v.menuopen then
				v.menuopen(self, menu2, ent, tr)
			end
		end

		if not hit then
			menu:Remove()
		end
	end,

	Action = function() end,
}

properties.Add('ulxpp', Property)

local function CreateLoop(start, End, step, format)
	return function(self, menu2, ent, tr)
		local sub = menu2:AddSubMenu()

		for i = start, End, step do
			sub:AddOption(string.format(format, i), function()
				RunConsoleCommand('ulx', menu2.command, menu2.nick, i)
			end)
		end
	end
end

ULXPP.AddProperty('slap', CreateLoop(5, 100, 5, '%s damage'))
ULXPP.AddProperty('slay')
ULXPP.AddProperty('sslay')
ULXPP.AddProperty('jail', CreateLoop(20, 120, 20, 'For %s seconds'))
ULXPP.AddProperty('sin', CreateLoop(5, 20, 5, 'For %s seconds'))
ULXPP.AddProperty('ignite', CreateLoop(20, 300, 20, 'For %s seconds'))
ULXPP.AddProperty('hp', CreateLoop(20, 500, 20, '%s hp'))
ULXPP.AddProperty('mhp', CreateLoop(20, 500, 20, '%s hp'))
ULXPP.AddProperty('unignite')
ULXPP.AddProperty('unjail')
ULXPP.AddProperty('unsin')
ULXPP.AddProperty('ip')
ULXPP.AddProperty('uid')
ULXPP.AddProperty('steamid64')
ULXPP.AddProperty('steamid')
ULXPP.AddProperty('profile')
ULXPP.AddProperty('freeze')
ULXPP.AddProperty('unfreeze')
ULXPP.AddProperty('loadout')
ULXPP.AddProperty('trainfuck')
ULXPP.AddProperty('rocket')
ULXPP.AddProperty('frespawn')
