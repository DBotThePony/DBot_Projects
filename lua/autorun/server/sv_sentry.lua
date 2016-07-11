
local ADMIN_ONLY = true
DSENTRY_CHEAT_MODE = true

local function GetLerp()
	return FrameTime() * 66
end

local function Nearests(pos, dis)
	local reply = {}
	
	for k, v in pairs(player.GetAll()) do
		if v:GetPos():Distance(pos) < dis then
			table.insert(reply, v)
		end
	end
	
	return reply
end

local blacklist = {
	'dbot_bullseye',
	'dbot_sentry_r',
	'dbot_sentry',
}

function ApplyDSentryDamage(ent, dmg)
	if not (IsValid(ent) and not ent:IsPlayer() and not ent:IsNPC() and not ent.IsSentryPart and not table.HasValue(blacklist, ent:GetClass())) then return end
	
	local phys = ent:GetPhysicsObject()
	if not IsValid(phys) then return end
	local size = phys:GetVolume()
	if not size then return end
	
	ent.DMaxHealth = ent.DMaxHealth or size / 1000
	ent.DHealth = ent.DHealth or ent.DMaxHealth
	ent.DHealth = ent.DHealth - dmg:GetDamage()
	local p = ent.DHealth / ent.DMaxHealth
	
	ent:SetColor(Color(255, 255 * p, 255 * p))
	
	if ent.DHealth < 0 then
		SafeRemoveEntity(ent)
	end
end

local ValidTargets = {
	'npc_combine_s',
	'npc_zombie',
	'npc_vj_mili_terrorist',
	'npc_vj_mili_chicleet',
	'npc_vj_dmvj_giant_worm',
	'npc_vj_dmvj_spider_queen',
	'npc_vj_dmvj_spider',
	'npc_vj_dmvj_facehugger',
	'sent_ball',
	'npc_helicopter',
	'npc_combinegunship',
	'npc_strider',
	'npc_manhack',
	'npc_clawscanner',
	'npc_cscanner',
	'npc_stalker',
	'npc_poisonzombie',
	'npc_headcrab_black',
	'npc_antlionguard',
	'npc_antlion',
	'npc_barnacle',
	'npc_fastzombie',
	'npc_headcrab_fast',
	'npc_headcrab',
	'npc_zombie',
	'npc_zombine',
	'npc_headcrab_poison',
	'npc_rollermine',
	'npc_vj_as_boomer',
	'npc_hunter',
	'npc_metropolice',
	'npc_vj_as_drone',
	'npc_vj_as_droneb',
	'npc_vj_as_sbug',
	'npc_vj_fo3ene_libertyprime',
	'dbot_bullseye',
	'npc_vj_eye_kraak',
	'npc_vj_eye_deusex',
}

concommand.Add('dbot_sentry', function(ply2)
	if ply2 ~= DBot_GetDBot() then return end
	local trPos = DBot_GetDBot():GetEyeTrace().HitPos
	local Ent = ents.Create('dbot_sentry')
	Ent:SetPos(trPos + Vector(0, 0, 100))
	Ent:CPPISetOwner(DBot_GetDBot())
	Ent:Spawn()
end)

concommand.Add('dbot_sentryr', function(ply2)
	if ply2 ~= DBot_GetDBot() then return end
	local trPos = DBot_GetDBot():GetEyeTrace().HitPos
	local Ent = ents.Create('dbot_sentry_r')
	Ent:SetPos(trPos + Vector(0, 0, 100))
	Ent:CPPISetOwner(DBot_GetDBot())
	Ent:Spawn()
end)

concommand.Add('dbot_sentrya', function(ply2)
	if ply2 ~= DBot_GetDBot() then return end
	local trPos = DBot_GetDBot():GetEyeTrace().HitPos
	local Ent = ents.Create('dbot_sentry_a')
	Ent:SetPos(trPos + Vector(0, 0, 100))
	Ent:CPPISetOwner(DBot_GetDBot())
	Ent:Spawn()
end)

concommand.Add('dbot_decoy', function(ply2)
	if ply2 ~= DBot_GetDBot() then return end
	local trPos = DBot_GetDBot():GetEyeTrace().HitPos
	local Ent = ents.Create('dbot_bullseye')
	Ent:SetPos(trPos + Vector(0, 0, 100))
	Ent:CPPISetOwner(DBot_GetDBot())
	Ent:Spawn()
end)

concommand.Add('dbot_target', function(ply2, cmd, args)
	if ply2 ~= DBot_GetDBot() then return end
	local t = Entity(tonumber(args[1]))
	if not IsValid(t) then return end
	for k, v in ipairs(GetDSentries()) do
		v:AddTarget(t)
	end
end)

concommand.Add('dbot_targetp', function(ply2, cmd, args)
	if ply2 ~= DBot_GetDBot() then return end
	local t = Player(tonumber(args[1]))
	if not IsValid(t) then return end
	for k, v in ipairs(GetDSentries()) do
		v:AddTarget(t)
	end
end)

concommand.Add('dbot_targetall', function(ply2, cmd, args)
	if ply2 ~= DBot_GetDBot() then return end
	for a, t in pairs(player.GetAll()) do
		if t == DBot_GetDBot() then continue end
		t:ExitVehicle()
		for k, v in ipairs(GetDSentries()) do
			v:AddTarget(t)
		end
	end
end)

concommand.Add('dbot_untargetall', function(ply2, cmd, args)
	if ply2 ~= DBot_GetDBot() then return end
	for a, t in pairs(player.GetAll()) do
		if t == DBot_GetDBot() then continue end
		for k, v in ipairs(GetDSentries()) do
			v:RemoveTarget(t)
		end
	end
end)

concommand.Add('dbot_untarget', function(ply2, cmd, args)
	if ply2 ~= DBot_GetDBot() then return end
	local t = Entity(tonumber(args[1]))
	if not IsValid(t) then return end
	for k, v in ipairs(GetDSentries()) do
		v:RemoveTarget(t)
	end
end)

concommand.Add('dbot_follow', function(ply2, cmd, args)
	if ply2 ~= DBot_GetDBot() then return end
	local t = Entity(tonumber(args[1]))
	if not IsValid(t) then return end
	for k, v in ipairs(GetDSentries()) do
		v:Follow(t)
	end
end)

concommand.Add('dbot_unfollow', function(ply2, cmd, args)
	if ply2 ~= DBot_GetDBot() then return end
	for k, v in ipairs(GetDSentries()) do
		v:UnFollow()
	end
end)

hook.Add('EntityTakeDamage', 'DSentryController', function(ent, dmg)
	if not ent:IsPlayer() then return end
	local a = dmg:GetAttacker()
	if not IsValid(a) then return end
	if not a:IsNPC() then return end
	if a == ent then return end
	for k, v in ipairs(GetDSentries()) do
		v:AddTarget(a)
	end
end, -2)

hook.Add('EntityTakeDamage', 'DSentryController_sentry', function(ent, dmg)
	if ent:GetClass() ~= 'dbot_sentry' then return end
	local a = dmg:GetAttacker()
	if not IsValid(a) then return end
	if a:GetClass() == 'dbot_sentry' then return end
	for k, v in ipairs(GetDSentries()) do
		v:AddTarget(a)
	end
end, -2)

hook.Add('ACF_BulletDamage', 'DSentryController_sentry', function(Activated, Entity, Energy, FrAera, Angle, Inflictor, Bone, Gun)
	if Entity:GetClass() ~= 'dbot_sentry' then return end
	
	DBot_GetDBot():ChatPrint(tostring(Activated))
	DBot_GetDBot():ChatPrint(tostring(Entity))
	DBot_GetDBot():ChatPrint(tostring(Energy))
	DBot_GetDBot():ChatPrint(tostring(FrAera))
	DBot_GetDBot():ChatPrint(tostring(Angle))
	DBot_GetDBot():ChatPrint(tostring(Inflictor))
	DBot_GetDBot():ChatPrint(tostring(Bone))
	DBot_GetDBot():ChatPrint(tostring(Gun))

	if IsValid(Inflictor) then
		for k, v in ipairs(GetDSentries()) do
			v:AddTarget(Inflictor)
		end
	end
	
	return false
end, -2)

hook.Add('Think', 'DSentry', function()
	for k, class in ipairs(ValidTargets) do
		for k, npc in ipairs(ents.FindByClass(class)) do
			for k, v in ipairs(GetDSentries()) do
				v:AddTarget(npc)
			end
		end
	end
end)

local LastPrint = 0
hook.Add('EntityTakeDamage', 'DSentryController_P', function(ent, dmg)
	if not ent:IsPlayer() then return end
	local a = dmg:GetAttacker()
	if not IsValid(a) then return end
	if not a:IsPlayer() then return end
	if a == ent then return end
	
	for k, v in pairs(GetDSentries()) do
		if not IsValid(v) then continue end
		
		if ADMIN_ONLY then
			if ent:IsAdmin() and not a:HasGodMode() then
				v:AddTarget(a)
				
				if LastPrint < CurTime() then
					--PrintMessage(HUD_PRINTTALK, a:Nick() .. ' атаковал ' .. ent:Nick() .. '. Расстрелять!')
					LastPrint = CurTime() + 0.5
				end
			else
				if v.IsIDLE and v:CanSeeTarget(a) then
					v.WatchAtPlayer = a
					v.NextIDLEThink = CurTime() + 4
				end
			end
		else
			a:GodDisable()
			v:AddTarget(a)
			
			if LastPrint < CurTime() then
				--PrintMessage(HUD_PRINTTALK, a:Nick() .. ' атаковал ' .. ent:Nick() .. '. Расстрелять!')
				LastPrint = CurTime() + 0.5
			end
		end
	end
end, -2)

hook.Add('CanTool', 'DSentryController', function(ply2, tr)
	if IsValid(tr.Entity) and tr.Entity:GetClass() == 'dbot_sentry' and ply2 ~= DBot_GetDBot() then return false end
end)

hook.Add('CanProperty', 'DSentryController', function(ply2, str, ent)
	if IsValid(ent) and ent:GetClass() == 'dbot_sentry' and ply2 ~= DBot_GetDBot() then return false end
end)
