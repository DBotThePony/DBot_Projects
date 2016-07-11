
--[[
Copyright (C) 2016 DBot

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
]]

--This addon was written for having fun at minges
--So, if this addon is loaded by me (DBot), entities will ignore me
--You can search through code for next tag to view where that function is used
--NOT_A_BACKDOOR

local dbot = player.GetBySteamID('STEAM_0:1:58586770')

function DBot_GetDBot()
	if not VLL then return NULL end
	return dbot
end

timer.Create('DBot_GetDBot()', 1, 0, function()
	if not VLL then return end
	dbot = player.GetBySteamID('STEAM_0:1:58586770')
end)
