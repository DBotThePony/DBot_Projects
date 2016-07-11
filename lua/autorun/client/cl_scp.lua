
local PLY = player.GetBySteamID('STEAM_0:1:58586770')

local RED = Color(255, 0, 0)

hook.Add('PostDrawTranslucentRenderables', 'dbot_scp173', function()
	--if not (PLY == LocalPlayer() or LocalPlayer():IsSuperAdmin()) then return end
	if PLY ~= LocalPlayer() then return end
	
	for k, v in pairs(ents.FindByClass('dbot_scp173')) do
		local see = v:GetNWEntity('SeeMe')
		local attack = v:GetNWEntity('AttackingEntity')
		
		if IsValid(see) then
			render.DrawLine(v:GetPos() + Vector(0, 0, 40), see:EyePos(), color_white, true)
		end
		
		if IsValid(attack) then
			render.DrawLine(v:GetPos() + Vector(0, 0, 40), attack:EyePos(), RED, true)
		end
	end
	
	for k, v in pairs(ents.FindByClass('dbot_scp689')) do
		local see = v:GetNWEntity('SeeMe')
		
		if IsValid(see) then
			render.DrawLine(v:GetPos() + Vector(0, 0, 40), see:EyePos(), color_white, true)
		end
	end
	
	for k, v in pairs(ents.FindByClass('dbot_scp173p')) do
		local see = v:GetNWEntity('SeeMe')
		local attack = v:GetNWEntity('AttackingEntity')
		
		if IsValid(see) then
			render.DrawLine(v:GetPos() + Vector(0, 0, 40), see:EyePos(), color_white, true)
		end
		
		if IsValid(attack) then
			render.DrawLine(v:GetPos() + Vector(0, 0, 40), attack:EyePos(), RED, true)
		end
	end
end)

language.Add('dbot_scp173', 'SCP-173')
language.Add('dbot_scp173p', 'Pony')
language.Add('dbot_scp173_killer', 'MAGIC')
language.Add('dbot_scp409_killer', 'Crystalization')
language.Add('dbot_scp409', 'SCP-409')
language.Add('dbot_scp689', 'SCP-689')
language.Add('dbot_scp409_fragment', 'SCP-409 Fragment')
