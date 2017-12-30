
-- Copyright (C) 2017-2018 DBot

-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at

--     http://www.apache.org/licenses/LICENSE-2.0

-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

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
