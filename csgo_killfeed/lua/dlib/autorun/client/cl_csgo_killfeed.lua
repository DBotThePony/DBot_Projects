
local blind_kill = Material('gui/csgo_killfeed/blind_kill.png')
local domination = Material('gui/csgo_killfeed/domination.png')
local headshot = Material('gui/csgo_killfeed/icon_headshot.png')
local suicide = Material('gui/csgo_killfeed/icon_suicide.png')
local noscope = Material('gui/csgo_killfeed/noscope.png')
local penetrate = Material('gui/csgo_killfeed/penetrate.png')
local revenge = Material('gui/csgo_killfeed/revenge.png')
local smoke_kill = Material('gui/csgo_killfeed/smoke_kill.png')
local flashbang_assist = Material('gui/csgo_killfeed/flashbang_assist.png')

local RealTime = RealTimeL
local DLib = DLib
local table = table
local net = net
local Color = Color
local LocalPlayer = LocalPlayer
local math = math
local ScreenSize = ScreenSize
local ipairs = ipairs
local surface = surface
local draw = draw

local TTL_DEFAULT = 3
local TTL_SELF = 6
local END_FADE = 0.7
local NPC_COLOR = Color(204, 214, 42)
local ENV_COLOR = Color(143, 0, 0)

local BACKGROUND = Color(0, 0, 0, 190)
local OUTLINE = Color(233, 94, 94)
local ASSIST_COLOR = Color(color_white)

surface.DLibCreateFont('CSGOKillfeed', {
	font = 'Roboto',
	size = 9,
	weight = 500,
	extended = true,
})

local history = {}

-- local POS = DLib.HUDCommons.Position2.DefinePosition('csgokillfeed', .92, .8)
local POS_X, POS_Y = .92, .08
local SPACING_TOP = 3
local SPACING_BETWEEN = 2
local SPACING_INITIAL = 4
local SPACING_LINES = 1

local function HUDPaint()
	--local X, Y = POS()
	local X, Y = POS_X * ScrW(), POS_Y * ScrH()

	local SPACING_TOP = ScreenSize(SPACING_TOP)
	local SPACING_BETWEEN = ScreenSize(SPACING_BETWEEN)
	local SPACING_INITIAL = ScreenSize(SPACING_INITIAL)
	local SPACING_LINES = ScreenSize(SPACING_LINES)
	--local fontspace = draw.GetFontHeight('CSGOKillfeed')
	surface.SetFont('CSGOKillfeed')
	local pluss, fontspace = surface.GetTextSize('+')

	for i, entry in ipairs(history) do
		local total_wide = SPACING_INITIAL * 2
		local _w, _h

		if entry.is_revenge then
			total_wide = total_wide + fontspace + SPACING_BETWEEN
		end

		if entry.is_headshot then
			total_wide = total_wide + fontspace + SPACING_BETWEEN
		end

		if entry.is_through_smoke then
			total_wide = total_wide + fontspace + SPACING_BETWEEN
		end

		if entry.is_penetrated_wall then
			total_wide = total_wide + fontspace + SPACING_BETWEEN
		end

		if entry.is_through_smoke then
			total_wide = total_wide + fontspace + SPACING_BETWEEN
		end

		if entry.is_domination then
			total_wide = total_wide + fontspace + SPACING_BETWEEN
		end

		if entry.is_blind_attacker then
			total_wide = total_wide + fontspace + SPACING_BETWEEN
		end

		if entry.pattacker then
			total_wide = total_wide + entry.pattacker_w + SPACING_BETWEEN
		end

		if entry.pis_assisted_by then
			total_wide = total_wide + entry.pis_assisted_by_w + SPACING_BETWEEN
		elseif entry.pblind_by_who then
			total_wide = total_wide + entry.pblind_by_who_w + SPACING_BETWEEN * 2 + fontspace
		end

		if entry.display_skull then
			total_wide = total_wide + fontspace + SPACING_BETWEEN
		else
			_w, _h = killicon.GetSize(entry.inflictor_class)
			total_wide = total_wide + _w + SPACING_BETWEEN
		end

		if entry.pvictim then
			total_wide = total_wide + entry.pvictim_w
		end

		draw.RoundedBox(4, X - total_wide, Y, total_wide, fontspace + SPACING_TOP * 2, entry.color)
		--surface.SetDrawColor(entry.color)
		--surface.DrawRect(X - total_wide, Y, total_wide, fontspace + SPACING_TOP * 2)

		surface.SetFont('CSGOKillfeed')

		local x = X - total_wide + SPACING_INITIAL

		if entry.is_revenge then
			surface.SetMaterial(revenge)
			surface.SetDrawColor(255, 255, 255, entry.alpha)
			surface.DrawTexturedRect(x, Y + SPACING_TOP, fontspace * 1.1, fontspace * 1.1)
			x = x + fontspace + SPACING_BETWEEN
		end

		if entry.is_domination then
			surface.SetMaterial(domination)
			surface.SetDrawColor(255, 255, 255, entry.alpha)
			surface.DrawTexturedRect(x, Y + SPACING_TOP, fontspace * 1.1, fontspace * 1.1)
			x = x + fontspace + SPACING_BETWEEN
		end

		if entry.is_blind_attacker then
			surface.SetMaterial(blind_kill)
			surface.SetDrawColor(255, 255, 255, entry.alpha)
			surface.DrawTexturedRect(x, Y + SPACING_TOP, fontspace * 1.1, fontspace * 1.1)
			x = x + fontspace + SPACING_BETWEEN
		end

		if entry.pattacker then
			surface.SetTextPos(x, Y + SPACING_TOP)
			surface.SetTextColor(entry.cattacker)
			surface.DrawText(entry.pattacker)
			x = x + entry.pattacker_w + SPACING_BETWEEN
		end

		if entry.pis_assisted_by then
			surface.SetTextPos(x, Y + SPACING_TOP)
			surface.SetTextColor(255, 255, 255, entry.alpha)
			surface.DrawText('+')
			x = x + pluss + SPACING_BETWEEN

			surface.SetTextPos(x, Y + SPACING_TOP)
			surface.SetTextColor(entry.cis_assisted_by)
			surface.DrawText(entry.pis_assisted_by)
			x = x + entry.pis_assisted_by_w + SPACING_BETWEEN
		elseif entry.pblind_by_who then
			surface.SetTextPos(x, Y + SPACING_TOP)
			surface.SetTextColor(255, 255, 255, entry.alpha)
			surface.DrawText('+')
			x = x + pluss + SPACING_BETWEEN

			surface.SetMaterial(flashbang_assist)
			surface.SetDrawColor(255, 255, 255, entry.alpha)
			surface.DrawTexturedRect(x, Y + SPACING_TOP, fontspace * 1.1, fontspace * 1.1)
			x = x + fontspace + SPACING_BETWEEN * 2

			surface.SetTextPos(x, Y + SPACING_TOP)
			surface.SetTextColor(entry.cblind_by_who)
			surface.DrawText(entry.pblind_by_who)
			x = x + entry.pblind_by_who_w + SPACING_BETWEEN
		end

		if entry.display_skull then
			surface.SetMaterial(suicide)
			surface.SetDrawColor(255, 255, 255, entry.alpha)
			surface.DrawTexturedRect(x, Y + SPACING_TOP, fontspace * 1.1, fontspace * 1.1)
			x = x + fontspace + SPACING_BETWEEN
		else
			killicon.Draw(x + _w / 2, Y + SPACING_TOP, entry.inflictor_class, entry.alpha)
			x = x + _w + SPACING_BETWEEN
			surface.SetFont('CSGOKillfeed')
		end

		if entry.is_through_smoke then
			surface.SetMaterial(smoke_kill)
			surface.SetDrawColor(255, 255, 255, entry.alpha)
			surface.DrawTexturedRect(x, Y + SPACING_TOP, fontspace * 1.1, fontspace * 1.1)
			x = x + fontspace + SPACING_BETWEEN
		end

		if entry.is_penetrated_wall then
			surface.SetMaterial(penetrate)
			surface.SetDrawColor(255, 255, 255, entry.alpha)
			surface.DrawTexturedRect(x, Y + SPACING_TOP, fontspace * 1.1, fontspace * 1.1)
			x = x + fontspace + SPACING_BETWEEN
		end

		if entry.is_headshot then
			surface.SetMaterial(headshot)
			surface.SetDrawColor(255, 255, 255, entry.alpha)
			surface.DrawTexturedRect(x, Y + SPACING_TOP, fontspace * 1.1, fontspace * 1.1)
			x = x + fontspace + SPACING_BETWEEN
		end

		if entry.pvictim then
			surface.SetTextPos(x, Y + SPACING_TOP)
			surface.SetTextColor(entry.cvictim)
			surface.DrawText(entry.pvictim)
			x = x + entry.pvictim_w
		end

		Y = Y + fontspace + SPACING_TOP * 2 + SPACING_LINES
	end
end

local function Think()
	local toremove
	local time = RealTime()

	for i, entry in ipairs(history) do
		local perc = 1 - time:progression(entry.start_fade, entry.end_fade)
		entry.perc = perc
		entry.alpha = math.floor(255 * perc)

		if entry.outline then
			entry.outline:SetAlpha(entry.alpha)
		end

		entry.cattacker:SetAlpha(entry.alpha)
		entry.cvictim:SetAlpha(entry.alpha)
		entry.color:SetAlpha(BACKGROUND.a * perc)

		if time > entry.end_fade then
			toremove = toremove or {}
			table.insert(toremove, i)
		end
	end

	if toremove then
		table.removeValues(history, toremove)
	end
end

local function getcolor(is_valid, entity_in)
	if not IsValid(entity_in) then
		return is_valid and NPC_COLOR or ENV_COLOR
	end

	if entity_in:IsPlayer() then
		return team.GetColor(entity_in:Team() or 1000) or color_white
	end

	return NPC_COLOR
end

local function doset(name, entry)
	if entry[name] then
		entry[name .. '_w'], entry[name .. '_h'] = surface.GetTextSize(entry[name])
	end
end

local function refresh_text_size(entry)
	surface.SetFont('CSGOKillfeed')

	doset('pattacker', entry)
	doset('pvictim', entry)
	doset('pinflictor', entry)
	doset('pis_assisted_by', entry)
	doset('pblind_by_who', entry)
end

local function csgo_killfeed()
	local is_headshot = net.ReadBool()
	local is_blind = net.ReadBool()
	local blind_by_who = is_blind and net.ReadEntity()
	local pblind_by_who = is_blind and net.ReadString()
	local is_blind_attacker = net.ReadBool()
	local is_assisted = net.ReadBool()
	local is_assisted_by = is_assisted and net.ReadEntity()
	local pis_assisted_by = is_assisted and net.ReadString()

	local is_through_smoke = net.ReadBool()
	local is_noscope = net.ReadBool()
	local is_penetrated_wall = net.ReadBool()
	local is_revenge = net.ReadBool()
	local is_domination = net.ReadBool()

	local lply = LocalPlayer()
	local victim, victim_class, pvictim = net.ReadEntity(), net.ReadString(), net.ReadString()
	local is_not_suicide = net.ReadBool()
	local attacker, inflictor, pattacker, pinflictor, inflictor_class, attacker_class

	if is_not_suicide then
		attacker = net.ReadEntity()
		attacker_class = net.ReadString()
		pattacker = net.ReadString()
	end

	local is_inflictor_valid = net.ReadBool()

	if is_inflictor_valid then
		inflictor = net.ReadEntity()
		inflictor_class = net.ReadString()
		pinflictor = net.ReadString()
	end

	local ttl = victim ~= lply and attacker ~= lply and inflictor ~= lply and TTL_DEFAULT or TTL_SELF

	local entry = {
		is_headshot = is_headshot,
		is_blind = is_blind,
		blind_by_who = blind_by_who,
		is_blind_attacker = is_blind_attacker,
		is_assisted = is_assisted,
		is_assisted_by = is_assisted_by,
		is_through_smoke = is_through_smoke,
		is_noscope = is_noscope,
		is_penetrated_wall = is_penetrated_wall,
		is_revenge = is_revenge,
		is_domination = is_domination,

		-- is_headshot = true,
		-- is_blind = true,
		-- blind_by_who = attacker,
		-- is_blind_attacker = true,
		-- is_assisted = true,
		-- is_assisted_by = attacker,
		-- is_through_smoke = true,
		-- is_noscope = true,
		-- is_penetrated_wall = true,
		-- is_revenge = true,
		-- is_domination = true,

		start_fade = RealTime() + ttl,
		end_fade = RealTime() + ttl + END_FADE,
		suicide = not is_not_suicide,

		highlight = ttl == TTL_SELF,

		alpha = 255,
		perc = 1,

		attacker = attacker,
		victim = victim,
		inflictor = inflictor,
		inflictor_class = inflictor_class,
		display_skull = not attacker or not inflictor_class or not killicon.Exists(inflictor_class),
		--display_skull = true,

		color = Color(BACKGROUND),
		outline = ttl == TTL_SELF and Color(OUTLINE),

		pattacker = IsValid(attacker) and attacker:GetPrintNameDLib() or pattacker,
		pvictim = IsValid(victim) and victim:GetPrintNameDLib() or pvictim,
		pinflictor = IsValid(inflictor) and inflictor:GetPrintNameDLib() or pinflictor,
		pis_assisted_by = IsValid(is_assisted_by) and is_assisted_by:GetPrintNameDLib() or pis_assisted_by,
		pblind_by_who = IsValid(blind_by_who) and blind_by_who:GetPrintNameDLib() or pblind_by_who,
		-- pis_assisted_by = IsValid(attacker) and attacker:GetPrintNameDLib() or attacker,
		-- pblind_by_who = IsValid(attacker) and attacker:GetPrintNameDLib() or attacker,

		cattacker = Color(getcolor(is_not_suicide, attacker)),
		cvictim = Color(getcolor(true, victim)),
		cis_assisted_by = Color(getcolor(is_assisted, is_assisted_by)),
		cblind_by_who = Color(getcolor(is_blind, blind_by_who)),
		-- cis_assisted_by = Color(getcolor(true, attacker)),
		-- cblind_by_who = Color(getcolor(true, attacker)),
		-- cinflictor = IsValid(inflictor) and inflictor:GetPrintNameDLib(),
	}

	refresh_text_size(entry)

	table.insert(history, entry)
end

local function AddDeathNotice()
	return false
end

net.receive('csgo_killfeed', csgo_killfeed)
hook.Add('Think', 'CSGOKillfeed', Think)
hook.Add('HUDPaint', 'CSGOKillfeed', HUDPaint)
hook.Add('AddDeathNotice', 'CSGOKillfeed', AddDeathNotice, -2)
hook.Add('DrawDeathNotice', 'CSGOKillfeed', AddDeathNotice, -2)
