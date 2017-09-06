
--
-- Copyright (C) 2017 DBot
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

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
