
--
-- Copyright (C) 2017 DBot

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


-- FIND1 = {}
-- FIND2 = {}
-- FIND3 = {}

-- timer.Create('DBot.SCP173_UpdateEnts', 3, 0, function()
-- 	if DBot_GetDBot() ~= LocalPlayer() then return end
-- 	FIND1 = ents.FindByClass('dbot_scp173')
-- 	FIND2 = ents.FindByClass('dbot_scp689')
-- 	FIND3 = ents.FindByClass('dbot_scp173p')
-- end)

-- RED = Color(255, 0, 0)

-- hook.Add('PostDrawTranslucentRenderables', 'dbot_scp173', function()
-- 	if DBot_GetDBot() ~= LocalPlayer() then return end
	
-- 	for k, v in ipairs(FIND1) do
-- 		local see = v:GetNWEntity('SeeMe')
-- 		local attack = v:GetNWEntity('AttackingEntity')
		
-- 		if IsValid(see) then
-- 			render.DrawLine(v:GetPos() + Vector(0, 0, 40), see:EyePos(), color_white, true)
-- 		end
		
-- 		if IsValid(attack) then
-- 			render.DrawLine(v:GetPos() + Vector(0, 0, 40), attack:EyePos(), RED, true)
-- 		end
-- 	end
	
-- 	for k, v in ipairs(FIND2) do
-- 		local see = v:GetNWEntity('SeeMe')
		
-- 		if IsValid(see) then
-- 			render.DrawLine(v:GetPos() + Vector(0, 0, 40), see:EyePos(), color_white, true)
-- 		end
-- 	end
	
-- 	for k, v in ipairs(FIND3) do
-- 		local see = v:GetNWEntity('SeeMe')
-- 		local attack = v:GetNWEntity('AttackingEntity')
		
-- 		if IsValid(see) then
-- 			render.DrawLine(v:GetPos() + Vector(0, 0, 40), see:EyePos(), color_white, true)
-- 		end
		
-- 		if IsValid(attack) then
-- 			render.DrawLine(v:GetPos() + Vector(0, 0, 40), attack:EyePos(), RED, true)
-- 		end
-- 	end
-- end)

import language from _G

language.Add('dbot_scp173', 'SCP-173')
language.Add('dbot_scp173p', 'Pony')
language.Add('dbot_scp173_killer', 'MAGIC')
language.Add('dbot_scp409_killer', 'Crystalization')
language.Add('dbot_scp409', 'SCP-409')
language.Add('dbot_scp689', 'SCP-689')
language.Add('dbot_scp409_fragment', 'SCP-409 Fragment')
