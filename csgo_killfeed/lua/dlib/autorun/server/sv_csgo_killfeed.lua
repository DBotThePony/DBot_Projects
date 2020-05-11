
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
	local dmginfo2 = DLib.LTakeDamageInfo(dmginfo)

	net.Start('csgo_killfeed', true)
	gather('', ply, attacker, dmginfo2, dmginfo)
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

	local inflictor = dmginfo2:GetInflictor()

	if IsValid(inflictor) and inflictor ~= ply then
		net.WriteBool(true)
		net.WriteEntity(inflictor)
		net.WriteString(inflictor.GetClass and inflictor:GetClass() or '')
		net.WriteString(inflictor:GetPrintNameDLib())
	else
		net.WriteBool(false)
	end

	net.Broadcast()
end

local lastdmginfo, lastent, lasttime

local function EntityTakeDamage(self, dmginfo)
	lastdmginfo = dmginfo
	lastent = self
	lasttime = CurTime()
end

local function OnNPCKilled(npc, attacker, inflictor)
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
end

hook.Add('DoPlayerDeath', 'DCSGO_Killfeed', DoPlayerDeath, 4)
hook.Add('OnNPCKilled', 'DCSGO_Killfeed', OnNPCKilled, 4)
hook.Add('EntityTakeDamage', 'DCSGO_Killfeed', EntityTakeDamage, 2)
