
-- public domain

local ADDON = 'Limited Flashlight and Oxygen'

timer.Simple(0, function()
	timer.Simple(0, function()
		timer.Simple(0, function()
			if DLib then return end

			if CLIENT then
				Derma_Query(
					ADDON .. ' requires DLib to Run! Without DLib, ' .. ADDON .. ' would not do anything!\nGet it on workshop (or gitlab)',
					ADDON .. ' requires DLib!',
					'Open Workshop',
					function() gui.OpenURL('https://steamcommunity.com/sharedfiles/filedetails/?id=1153306104') end,
					'Open GitLab',
					function() gui.OpenURL('https://gitlab.com/DBotThePony/DLib') end
				)
			else
				MsgC('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n')
				MsgC(ADDON .. ' requires DLib to Run! Without DLib, ' .. ADDON .. ' would not do anything!\nGet it on workshop (or gitlab)\n')
				MsgC('https://steamcommunity.com/sharedfiles/filedetails/?id=1153306104\n')
				MsgC('https://gitlab.com/DBotThePony/DLib\n')
				MsgC('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n')
			end
		end)
	end)
end)
