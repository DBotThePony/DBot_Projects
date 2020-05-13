
-- Copyright (C) 2020 DBotThePony

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

local ENABLED_SV = CreateConVar('sv_csgokillfeed', '1', {FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE}, 'Enable CS:GO Killfeed')

net.pool('csgo_killfeed')

local function gather(prefix, ...)
	local is_headshot = hook.Run('DCSGO_IsHeadshot' .. prefix, ...)
	local is_blind, blind_by_who = hook.Run('DCSGO_IsBlindVictim' .. prefix, ...)
	local is_blind_attacker = hook.Run('DCSGO_IsBlindAttacker' .. prefix, ...)
	local is_assisted_by = hook.Run('DCSGO_IsAssisted' .. prefix, ...)
	local is_through_smoke = hook.Run('DCSGO_IsKillThroughSmoke' .. prefix, ...)
	local is_noscope = hook.Run('DCSGO_IsKillNoscope' .. prefix, ...)
	local is_penetrated_wall = hook.Run('DCSGO_IsWallPenetrated' .. prefix, ...)
	local is_revenge = hook.Run('DCSGO_IsRevenge' .. prefix, ...)
	local is_domination = hook.Run('DCSGO_IsDomination' .. prefix, ...)

	net.WriteBool(is_headshot == true)
	net.WriteBool(is_blind == true)

	if is_blind then
		net.WriteEntity(blind_by_who)
		net.WriteString(blind_by_who:GetPrintNameDLib())
	end

	net.WriteBool(is_blind_attacker == true)

	net.WriteBool(is_assisted_by and IsValid(is_assisted_by))

	if is_assisted_by and IsValid(is_assisted_by) then
		net.WriteEntity(is_assisted_by)
		net.WriteString(is_assisted_by:GetPrintNameDLib())
	end

	net.WriteBool(is_through_smoke == true)
	net.WriteBool(is_noscope == true)
	net.WriteBool(is_penetrated_wall == true)
	net.WriteBool(is_revenge == true)
	net.WriteBool(is_domination == true)
end

local function DoPlayerDeath(ply, attacker, dmginfo)
	if not ENABLED_SV:GetBool() then return end

	local dmginfo2 = DLib.LTakeDamageInfo(dmginfo)

	local inflictor = dmginfo2:GetInflictor()

	if not IsValid(inflictor) or inflictor == attacker then
		inflictor = dmginfo2:GetInflictor()
	end

	if not IsValid(inflictor) or inflictor == attacker then
		inflictor = attacker.GetActiveWeapon and attacker:GetActiveWeapon()
	end

	local updategroup = false

	if ply.__DCSGO_LastGroupAt == CurTime() then
		updategroup = true
	end

	timer.Simple(0, function()
		if not IsValid(ply) then return end

		if updategroup then
			ply.__DCSGO_LastGroupAt = CurTime()
		end

		net.Start('csgo_killfeed', true)
		gather('', ply, attacker, dmginfo2, dmginfo, inflictor)

		net.WriteEntity(ply)
		net.WriteString('player')
		net.WriteString(ply:GetPrintNameDLib())

		if IsValid(attacker) and attacker ~= ply then
			net.WriteBool(true)
			net.WriteEntity(attacker)
			net.WriteString(attacker.GetClass and attacker:GetClass() or '')
			net.WriteString(attacker:GetPrintNameDLib())
		else
			net.WriteBool(false)
		end

		if IsValid(inflictor) and inflictor ~= ply then
			net.WriteBool(true)
			net.WriteEntity(inflictor)
			net.WriteString(inflictor.GetClass and inflictor:GetClass() or '')
			net.WriteString(inflictor:GetPrintNameDLib())
		else
			net.WriteBool(false)
		end

		net.Broadcast()
	end)
end

local lastdmginfo, lastent, lasttime

local function EntityTakeDamage(self, dmginfo)
	lastdmginfo = dmginfo
	lastent = self
	lasttime = CurTime()
end

local function OnNPCKilled(npc, attacker, inflictor)
	if not ENABLED_SV:GetBool() then return end

	local dmginfo

	if lastent == npc and lasttime == CurTime() then
		dmginfo = lastdmginfo
	end

	if not dmginfo then return end

	local dmginfo2 = DLib.LTakeDamageInfo(dmginfo)

	if not IsValid(inflictor) or inflictor == attacker then
		inflictor = dmginfo2:GetInflictor()
	end

	if not IsValid(inflictor) or inflictor == attacker then
		inflictor = attacker.GetActiveWeapon and attacker:GetActiveWeapon()
	end

	local updategroup = false

	if npc.__DCSGO_LastGroupAt == CurTime() then
		updategroup = true
	end

	timer.Simple(0, function()
		if not IsValid(npc) then return end

		if updategroup then
			npc.__DCSGO_LastGroupAt = CurTime()
		end

		net.Start('csgo_killfeed', true)
		gather('_NPC', npc, attacker, dmginfo2, dmginfo, inflictor)

		net.WriteEntity(npc)
		net.WriteString(npc:GetClass() or '')
		net.WriteString(npc:GetPrintNameDLib())

		if IsValid(attacker) and attacker ~= npc then
			net.WriteBool(true)
			net.WriteEntity(attacker)
			net.WriteString(attacker.GetClass and attacker:GetClass() or '')
			net.WriteString(attacker:GetPrintNameDLib())
		else
			net.WriteBool(false)
		end

		if IsValid(inflictor) and inflictor ~= npc and inflictor ~= attacker then
			net.WriteBool(true)
			net.WriteEntity(inflictor)
			net.WriteString(inflictor.GetClass and inflictor:GetClass() or '')
			net.WriteString(inflictor:GetPrintNameDLib())
		else
			net.WriteBool(false)
		end

		net.Broadcast()
	end)
end

local function ScaleNPCDamage(self, group, dmginfo)
	if self.__DCSGO_LastGroupAt == CurTime() and self.__DCSGO_LastGroup ~= HITGROUP_HEAD and group == HITGROUP_HEAD then
		self.__DCSGO_LastGroup = group
	elseif self.__DCSGO_LastGroupAt ~= CurTime() then
		self.__DCSGO_LastGroup = group
		self.__DCSGO_LastGroupAt = CurTime()
	end
end

hook.Add('DoPlayerDeath', 'DCSGO_Killfeed', DoPlayerDeath, 4)
hook.Add('OnNPCKilled', 'DCSGO_Killfeed', OnNPCKilled, 4)
hook.Add('ScaleNPCDamage', 'DCSGO_Killfeed', ScaleNPCDamage, -1)
hook.Add('ScalePlayerDamage', 'DCSGO_Killfeed', ScaleNPCDamage, -1)
hook.Add('EntityTakeDamage', 'DCSGO_Killfeed', EntityTakeDamage, 2)

local function DCSGO_IsKillNoscope(victim, attacker, dmginfo, _, inflictor)
	if IsValid(inflictor) and inflictor.IsTFA and inflictor:IsTFA() then
		if not inflictor.DrawCrosshair and inflictor.IronSightsProgress < 0.5 and (not inflictor.data or not inflictor.data.ironsights or inflictor.data.ironsights ~= 0) then
			return true
		end
	end
end

local function DCSGO_IsBlindVictim(victim, attacker, dmginfo, _, inflictor)
	if TFA_CSGO_FlashIntensity and TFA_CSGO_FlashIntensity(victim) > 0.5 then
		return true, victim:GetNWEntity('TFACSGO_LastFlashBy')
	end
end

local function DCSGO_IsBlindAttacker(victim, attacker, dmginfo, _, inflictor)
	if IsValid(attacker) and TFA_CSGO_FlashIntensity and TFA_CSGO_FlashIntensity(attacker) > 0.5 then
		return true
	end
end

local function DCSGO_IsWallPenetrated(victim, attacker, dmginfo, _, inflictor)
	if not IsValid(victim.DCSGO_LastPenetrationBy) or victim.DCSGO_LastPenetrationBy ~= attacker then return end

	local cond =
		victim.DCSGO_LastPenetrationDmg:GetAttacker() == dmginfo:GetAttacker() and
		victim.DCSGO_LastPenetrationDmg:GetInflictor() == inflictor

	if cond then
		return true
	end
end

local function TFA_BulletPenetration(self, attacker, tr, dmginfo)
	if tr.Hit and IsValid(tr.Entity) then
		tr.Entity.DCSGO_LastPenetrationBy = attacker
		tr.Entity.DCSGO_LastPenetrationAt = CurTime()
		tr.Entity.DCSGO_LastPenetrationDmg = DLib.LTakeDamageInfo(dmginfo)
	end
end

local function DCSGO_IsHeadshot(self, attacker, tr, dmginfo)
	if self.__DCSGO_LastGroup == HITGROUP_HEAD and self.__DCSGO_LastGroupAt == CurTime() then
		return true
	end
end

hook.Add('DCSGO_IsKillNoscope', 'DCSGO_Defaults', DCSGO_IsKillNoscope, 5)
hook.Add('DCSGO_IsKillNoscope_NPC', 'DCSGO_Defaults', DCSGO_IsKillNoscope, 5)
hook.Add('DCSGO_IsBlindVictim', 'DCSGO_Defaults', DCSGO_IsBlindVictim, 5)
hook.Add('DCSGO_IsBlindVictim_NPC', 'DCSGO_Defaults', DCSGO_IsBlindVictim, 5)
hook.Add('DCSGO_IsBlindAttacker', 'DCSGO_Defaults', DCSGO_IsBlindAttacker, 5)
hook.Add('DCSGO_IsBlindAttacker_NPC', 'DCSGO_Defaults', DCSGO_IsBlindAttacker, 5)
hook.Add('DCSGO_IsWallPenetrated', 'DCSGO_Defaults', DCSGO_IsWallPenetrated, 5)
hook.Add('DCSGO_IsWallPenetrated_NPC', 'DCSGO_Defaults', DCSGO_IsWallPenetrated, 5)
hook.Add('DCSGO_IsHeadshot', 'DCSGO_Defaults', DCSGO_IsHeadshot, 5)
hook.Add('DCSGO_IsHeadshot_NPC', 'DCSGO_Defaults', DCSGO_IsHeadshot, 5)
hook.Add('TFA_BulletPenetration', 'DCSGO_Defaults', TFA_BulletPenetration)
