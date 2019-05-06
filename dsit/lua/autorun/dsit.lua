
-- Copyright (C) 2017-2019 DBotThePony

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


local ADDON = 'DSit'

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
