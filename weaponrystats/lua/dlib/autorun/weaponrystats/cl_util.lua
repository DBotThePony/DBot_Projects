
-- Copyright (C) 2017-2019 DBot

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


local weaponrystats = weaponrystats

local PREFIX = '[WeaponryStats] '
local PREFIX_COLOR = Color(0, 200, 0)

function weaponrystats.Chat(...)
	local formatted = weaponrystats.FormatMessage({...})
	chat.AddText(PREFIX_COLOR, PREFIX, unpack(formatted))
	return formatted
end

net.Receive('WPS.Notify', function()
	local statusType = net.ReadUInt(8)
	local readTab = net.ReadTable()
	if statusType == weaponrystats.NOTIFY_CONSOLE then
		weaponrystats.Message(unpack(readTab))
	elseif statusType == weaponrystats.NOTIFY_CHAT then
		weaponrystats.Chat(unpack(readTab))
	else
		weaponrystats.Message(unpack(readTab))
		weaponrystats.Chat(unpack(readTab))
	end
end)
