-- public domain - DBotThePony

--This addon was written for having fun at minges
--So, if this addon is loaded by me (DBot), entities will ignore me
--You can search through code for next tag to view where that function is used
--NOT_A_BACKDOOR

local dbot = player.GetBySteamID('STEAM_0:1:58586770')

function DBot_GetDBot()
	if not VLL and not VLL2 then return NULL end
	return dbot
end

timer.Create('DBot_GetDBot()', 1, 0, function()
	if not VLL and not VLL2 then return end
	dbot = player.GetBySteamID('STEAM_0:1:58586770')
end)
