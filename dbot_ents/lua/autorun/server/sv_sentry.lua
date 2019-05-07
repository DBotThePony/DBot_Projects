-- public domain - DBotThePony

local ADMIN_ONLY = true
local ATTACK_PLAYERS_AT_ALL = false
DSENTRY_CHEAT_MODE = false

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

--Heh
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

local function CreateUndo(Name, ent)
	undo.Create(Name)
	undo.AddFunction(function()
		ent.delet = true
		ent:Remove()
	end)
	undo.SetPlayer(DBot_GetDBot())
	undo.Finish()
end

local Commands = {
	sentry = function(ply2)
		local trPos = DBot_GetDBot():GetEyeTrace().HitPos
		local Ent = ents.Create('dbot_sentry')
		Ent:SetPos(trPos + Vector(0, 0, 100))
		Ent:CPPISetOwner(DBot_GetDBot())
		Ent:Spawn()
		CreateUndo('Sentry', Ent)
	end,

	sentryr = function(ply2)
		local trPos = DBot_GetDBot():GetEyeTrace().HitPos
		local Ent = ents.Create('dbot_sentry_r')
		Ent:SetPos(trPos + Vector(0, 0, 100))
		Ent:CPPISetOwner(DBot_GetDBot())
		Ent:Spawn()
		CreateUndo('Rocket Sentry', Ent)
	end,

	sentrya = function(ply2)
		local trPos = DBot_GetDBot():GetEyeTrace().HitPos
		local Ent = ents.Create('dbot_sentry_a')
		Ent:SetPos(trPos + Vector(0, 0, 100))
		Ent:CPPISetOwner(DBot_GetDBot())
		Ent:Spawn()
	end,

	delet = function(ply2)
		for k, v in ipairs(GetDSentries()) do
			v.delet = true
			v:Remove()
		end
	end,

	decoy = function(ply2)
		local trPos = DBot_GetDBot():GetEyeTrace().HitPos
		local Ent = ents.Create('dbot_bullseye')
		Ent:SetPos(trPos + Vector(0, 0, 100))
		Ent:CPPISetOwner(DBot_GetDBot())
		Ent:Spawn()
		CreateUndo('Decoy', Ent)
	end,

	target = function(ply2, cmd, args)
		local t = Entity(tonumber(args[1]))
		if not IsValid(t) then return end
		for k, v in ipairs(GetDSentries()) do
			v:AddTarget(t)
		end
	end,

	targetpprops = function(ply2, cmd, args)
		local t = Entity(tonumber(args[1]))
		if not IsValid(t) then return end
		local sentrys = GetDSentries()

		for k, ent in ipairs(DPP.GetEntsByUID(t:UniqueID())) do
			for k, v in ipairs(sentrys) do
				v:AddTarget(ent)
			end
		end
	end,

	targetp = function(ply2, cmd, args)
		local t = Player(tonumber(args[1]))
		if not IsValid(t) then return end
		for k, v in ipairs(GetDSentries()) do
			v:AddTarget(t)
		end
	end,

	targetall = function(ply2, cmd, args)
		for a, t in pairs(player.GetAll()) do
			if t == DBot_GetDBot() then continue end
			t:ExitVehicle()
			for k, v in ipairs(GetDSentries()) do
				v:AddTarget(t)
			end
		end
	end,

	untargetall = function(ply2, cmd, args)
		for a, t in pairs(player.GetAll()) do
			if t == DBot_GetDBot() then continue end
			for k, v in ipairs(GetDSentries()) do
				v:RemoveTarget(t)
			end
		end
	end,

	untarget = function(ply2, cmd, args)
		local t = Entity(tonumber(args[1]))
		if not IsValid(t) then return end
		for k, v in ipairs(GetDSentries()) do
			v:RemoveTarget(t)
		end
	end,

	follow = function(ply2, cmd, args)
		local t = Entity(tonumber(args[1]))
		if not IsValid(t) then return end
		for k, v in ipairs(GetDSentries()) do
			v:Follow(t)
		end
	end,

	unfollow = function(ply2, cmd, args)
		for k, v in ipairs(GetDSentries()) do
			v:UnFollow()
		end
	end,
}

for k, v in pairs(Commands) do
	concommand.Add('dbot_' .. k, function(ply, ...)
		if ply ~= DBot_GetDBot() then return end
		v(ply, ...)
	end)
end

local Invalid = {
	['dbot_scp409'] = true,
}

local function EntityTakeDamage(ent, dmg)
	if ent:IsPlayer() then
		local a = dmg:GetAttacker()
		if not IsValid(a) then return end
		if a == ent then return end

		local class = a:GetClass()

		if a:IsNPC() then
			for k, v in ipairs(GetDSentries()) do
				v:AddTarget(a)
			end
		elseif not Invalid[class] then
			local owner = a.CPPIGetOwner and a:CPPIGetOwner()

			for k, v in pairs(GetDSentries()) do
				if not IsValid(v) then continue end

				v:AddTarget(a)

				if IsValid(owner) and owner ~= ent then
					if ADMIN_ONLY then
						if ent:IsAdmin() and not owner:HasGodMode() then
							v:AddTarget(owner)
						else
							if v.IsIDLE and v:CanSeeTarget(owner) then
								v.WatchAtPlayer = owner
								v.NextIDLEThink = CurTimeL() + 4
							end
						end
					else
						owner:GodDisable()
						v:AddTarget(owner)
					end
				end
			end
		elseif a:IsPlayer() and ATTACK_PLAYERS_AT_ALL then
			for k, v in pairs(GetDSentries()) do
				if not IsValid(v) then continue end

				if ADMIN_ONLY then
					if ent:IsAdmin() and not a:HasGodMode() then
						v:AddTarget(a)
					else
						if v.IsIDLE and v:CanSeeTarget(a) then
							v.WatchAtPlayer = a
							v.NextIDLEThink = CurTimeL() + 4
						end
					end
				else
					a:GodDisable()
					v:AddTarget(a)
				end
			end
		end
	elseif ent.IsDSentry then
		local a = dmg:GetAttacker()
		if not IsValid(a) then return end
		if a:GetClass() == 'dbot_sentry' then return end

		local inflictor = dmg:GetInflictor()
		local addInflictor = false

		if IsValid(inflictor) then
			addInflictor = not inflictor:IsWeapon() and inflictor.CPPIGetOwner and inflictor:CPPIGetOwner() == a
		end

		for k, v in ipairs(GetDSentries()) do
			v:AddTarget(a)

			if addInflictor then
				v:AddTarget(inflictor)
			end
		end
	end
end

local function ACF_BulletDamage(Activated, Entity, Energy, FrAera, Angle, Inflictor, Bone, Gun)
	if not Entity.IsDSentry then return end

	if IsValid(Inflictor) then
		for k, v in ipairs(GetDSentries()) do
			v:AddTarget(Inflictor)
		end
	end

	return false
end

local function Think()
	local get = GetDSentries()

	for k, class in ipairs(ValidTargets) do
		for k, npc in ipairs(ents.FindByClass(class)) do
			if npc.AddRelationship then
				npc:AddRelationship('dbot_sentry D_HT 1')
				npc:AddRelationship('dbot_sentry_r D_HT 1')
			end

			for k, sentry in ipairs(get) do
				sentry:AddTarget(npc)
			end
		end
	end
end

local function CanTool(ply, tr)
	if not IsValid(DBot_GetDBot()) then return end
	if IsValid(tr.Entity) and tr.Entity.IsDSentry and ply ~= DBot_GetDBot() then return false end
	if IsValid(tr.Entity) and tr.Entity.IsDSentry and ply == DBot_GetDBot() then tr.Entity.delet = true end
end

local function CanProperty(ply, str, ent)
	if not IsValid(DBot_GetDBot()) then return end
	if IsValid(ent) and ent.IsDSentry and ply ~= DBot_GetDBot() then return false end
	if IsValid(ent) and ent.IsDSentry and ply == DBot_GetDBot() then ent.delet = true end
end

local function OnNPCKilled(npc, wep, attacker)
	if not IsValid(attacker) then return end
	if not attacker.IsDSentry then return end
	attacker:SetFrags(attacker:GetFrags() + 1)
end

local function PlayerDeath(ply, wep, attacker)
	if not IsValid(attacker) then return end
	if not attacker.IsDSentry then return end
	attacker:SetPFrags(attacker:GetPFrags() + 1)
end

hook.Add('OnNPCKilled', 'DSentry', OnNPCKilled)
hook.Add('PlayerDeath', 'DSentry', PlayerDeath)
hook.Add('EntityTakeDamage', 'DSentry', EntityTakeDamage, -1)
hook.Add('ACF_BulletDamage', 'DSentry', ACF_BulletDamage, -2)
hook.Add('Think', 'DSentry', Think)
hook.Add('CanTool', 'DSentry', CanTool)
hook.Add('CanProperty', 'DSentry', CanProperty)
