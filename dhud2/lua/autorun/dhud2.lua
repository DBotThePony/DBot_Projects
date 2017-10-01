
-- Copyright (C) 2017 DBot

-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at

--     http://www.apache.org/licenses/LICENSE-2.0

-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

local ADDON = 'DHUD2'

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
					function() gui.OpenURL('http://git.dbot.serealia.ca/dbot/DLib') end
				)
			else
				MsgC('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n')
				MsgC(ADDON .. ' requires DLib to Run! Without DLib, ' .. ADDON .. ' would not do anything!\nGet it on workshop (or gitlab)\n')
				MsgC('https://steamcommunity.com/sharedfiles/filedetails/?id=1153306104\n')
				MsgC('http://git.dbot.serealia.ca/dbot/DLib\n')
				MsgC('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n')
			end
		end)
	end)
end)
