
local blind_kill = Material('gui/csgo_killfeed/blind_kill.png', 'noclamp smooth mips')
local domination = Material('gui/csgo_killfeed/domination.png', 'noclamp smooth mips')
local headshot = Material('gui/csgo_killfeed/icon_headshot.png', 'noclamp smooth mips')
local suicide = Material('gui/csgo_killfeed/icon_suicide.png', 'noclamp smooth mips')
local noscope = Material('gui/csgo_killfeed/noscope.png', 'noclamp smooth mips')
local penetrate = Material('gui/csgo_killfeed/penetrate.png', 'noclamp smooth mips')
local revenge = Material('gui/csgo_killfeed/revenge.png', 'noclamp smooth mips')
local smoke_kill = Material('gui/csgo_killfeed/smoke_kill.png', 'noclamp smooth mips')
local flashbang_assist = Material('gui/csgo_killfeed/flashbang_assist.png', 'noclamp smooth mips')

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
local render = render
local TEXFILTER = TEXFILTER

local TTL_DEFAULT = 5
local TTL_SELF = 10
local END_FADE = 0.7
local NPC_COLOR = Color(204, 214, 42)
local ENV_COLOR = Color(143, 0, 0)

local BACKGROUND = Color(0, 0, 0, 165)
local BACKGROUND_DEAD = ColorBE(0xa81313):SetAlpha(178)
local OUTLINE = ColorBE(0xe10000)
local ASSIST_COLOR = Color(color_white)

local function ScreenResolutionChanged()
	local size = ScreenSize(9):max(18):floor()

	surface.CreateFont('CSGOKillfeed', {
		font = 'Roboto',
		size = size,
		weight = 500,
		extended = true,
	})
end

ScreenResolutionChanged()

local history = {}

-- local POS = DLib.HUDCommons.Position2.DefinePosition('csgokillfeed', .92, .8)
local POS_X, POS_Y = .92, .08
local SPACING_TOP = 3
local SPACING_BETWEEN = 3
local SPACING_INITIAL = 4
local SPACING_LINES = 3
local SPACING_OUTLINE = 1

local function HUDPaint()
	--local X, Y = POS()
	local X, Y = (POS_X * ScrW()):round(), (POS_Y * ScrH()):round()

	local SPACING_TOP = ScreenSize(SPACING_TOP):round()
	local SPACING_BETWEEN = ScreenSize(SPACING_BETWEEN):round()
	local SPACING_INITIAL = ScreenSize(SPACING_INITIAL):round()
	local SPACING_LINES = ScreenSize(SPACING_LINES):round()
	local SPACING_OUTLINE = ScreenSize(SPACING_OUTLINE):round()
	--local fontspace = draw.GetFontHeight('CSGOKillfeed')
	surface.SetFont('CSGOKillfeed')
	local pluss, fontspace = surface.GetTextSize('+')

	render.PushFilterMag(TEXFILTER.ANISOTROPIC)
	render.PushFilterMin(TEXFILTER.ANISOTROPIC)

	for i, entry in ipairs(history) do
		local total_wide = SPACING_INITIAL * 2
		local _w, _h = entry.icon_w, entry.icon_h

		if entry.is_revenge then
			total_wide = total_wide + fontspace + SPACING_TOP * 2 + SPACING_BETWEEN
		end

		if entry.is_headshot then
			total_wide = total_wide + fontspace + SPACING_TOP * 2 + SPACING_BETWEEN
		end

		if entry.is_through_smoke then
			total_wide = total_wide + fontspace + SPACING_TOP * 2 + SPACING_BETWEEN
		end

		if entry.is_penetrated_wall then
			total_wide = total_wide + fontspace + SPACING_TOP * 2 + SPACING_BETWEEN
		end

		if entry.is_through_smoke then
			total_wide = total_wide + fontspace + SPACING_TOP * 2 + SPACING_BETWEEN
		end

		if entry.is_domination then
			total_wide = total_wide + fontspace + SPACING_TOP * 2 + SPACING_BETWEEN
		end

		if entry.is_blind_attacker then
			total_wide = total_wide + fontspace + SPACING_TOP * 2 + SPACING_BETWEEN
		end

		if entry.is_noscope then
			total_wide = total_wide + fontspace + SPACING_TOP * 2 + SPACING_BETWEEN
		end

		if entry.pattacker then
			total_wide = total_wide + entry.pattacker_w + SPACING_BETWEEN
		end

		if entry.pis_assisted_by then
			total_wide = total_wide + entry.pis_assisted_by_w + SPACING_BETWEEN
		elseif entry.pblind_by_who then
			total_wide = total_wide + entry.pblind_by_who_w + SPACING_BETWEEN * 3 + fontspace * 2
		end

		if entry.display_skull then
			total_wide = total_wide + fontspace + SPACING_TOP * 2 + SPACING_BETWEEN
		else
			total_wide = total_wide + entry.icon_w_mul + SPACING_BETWEEN
		end

		if entry.pvictim then
			total_wide = total_wide + entry.pvictim_w
		end

		total_wide = total_wide:round()

		-- draw.RoundedBox(4, X - total_wide, Y, total_wide, fontspace + SPACING_TOP * 2, entry.color)
		local bh = math.round(fontspace + SPACING_TOP * 2)

		if entry.highlight then
			local i = math.min(i, 255)
			render.SetStencilReferenceValue(i)
			render.SetStencilTestMask(i)
			render.SetStencilWriteMask(i)

			render.SetStencilEnable(true)

			render.SetStencilFailOperation(STENCIL_REPLACE)
			render.SetStencilPassOperation(STENCIL_REPLACE)
			render.SetStencilCompareFunction(STENCIL_ALWAYS)

			surface.SetDrawColor(entry.color)
			surface.DrawRect(X - total_wide, Y, total_wide, bh)

			render.SetStencilCompareFunction(STENCIL_NOTEQUAL)
		else
			draw.RoundedBox(4, X - total_wide, Y, total_wide, bh, entry.color)
		end

		-- wtf?
		-- this looks like there should always be a border, but it does appear only
		-- when getting kills as killer
		--[[
			.DeathNoticeBGBorder
			{
				border-radius: 3px;
				width: 100%;
				height: 100%;

				transition-property: opacity;
				transition-timing-function: ease-out;
				transition-duration: DeathNoticeFadeOutTime;
			}

			.DeathNotice_Killer .DeathNoticeBGBorder
			{
				border: 2px solid #e10000;
			}
		]]
		if entry.highlight then
			draw.RoundedBox(4, X - total_wide - SPACING_OUTLINE, Y - SPACING_OUTLINE, total_wide + SPACING_OUTLINE * 2, bh + SPACING_OUTLINE * 2, entry.highlight and entry.outline or color_black)

			render.SetStencilEnable(false)
		end

		surface.SetFont('CSGOKillfeed')

		local x = X - total_wide + SPACING_INITIAL

		if entry.is_revenge then
			surface.SetMaterial(revenge)
			surface.SetDrawColor(255, 255, 255, entry.alpha)
			surface.DrawTexturedRect(x, Y, fontspace + SPACING_TOP * 2, fontspace + SPACING_TOP * 2)
			x = x + fontspace + SPACING_TOP * 2 + SPACING_BETWEEN
		end

		if entry.is_domination then
			surface.SetMaterial(domination)
			surface.SetDrawColor(255, 255, 255, entry.alpha)
			surface.DrawTexturedRect(x, Y, fontspace + SPACING_TOP * 2, fontspace + SPACING_TOP * 2)
			x = x + fontspace + SPACING_TOP * 2 + SPACING_BETWEEN
		end

		if entry.is_blind_attacker then
			surface.SetMaterial(blind_kill)
			surface.SetDrawColor(255, 255, 255, entry.alpha)
			surface.DrawTexturedRect(x, Y, fontspace + SPACING_TOP * 2, fontspace + SPACING_TOP * 2)
			x = x + fontspace + SPACING_TOP * 2 + SPACING_BETWEEN
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
			surface.DrawTexturedRect(x, Y, fontspace + SPACING_TOP * 2, fontspace + SPACING_TOP * 2)
			x = x + fontspace + SPACING_TOP * 2 + SPACING_BETWEEN * 2

			surface.SetTextPos(x, Y + SPACING_TOP)
			surface.SetTextColor(entry.cblind_by_who)
			surface.DrawText(entry.pblind_by_who)
			x = x + entry.pblind_by_who_w + SPACING_BETWEEN
		end

		if entry.display_skull then
			surface.SetMaterial(suicide)
			surface.SetDrawColor(255, 255, 255, entry.alpha)
			surface.DrawTexturedRect(x, Y, fontspace + SPACING_TOP * 2, fontspace + SPACING_TOP * 2)
			x = x + fontspace + SPACING_TOP * 2 + SPACING_BETWEEN
		else
			_matrix = Matrix()
			_matrix:Scale(entry.vec_mul)
			_matrix:Translate(Vector(x * (1 / entry.mul), Y * (1 / entry.mul)))

			cam.PushModelMatrix(_matrix)
			killicon.Draw(_w / 2, _h * 0.3, entry.inflictor_class, entry.alpha)
			cam.PopModelMatrix()

			x = x + entry.icon_w_mul + SPACING_BETWEEN
			surface.SetFont('CSGOKillfeed')
		end

		if entry.is_noscope then
			surface.SetMaterial(noscope)
			surface.SetDrawColor(255, 255, 255, entry.alpha)
			surface.DrawTexturedRect(x, Y, fontspace + SPACING_TOP * 2, fontspace + SPACING_TOP * 2)
			x = x + fontspace + SPACING_TOP * 2 + SPACING_BETWEEN
		end

		if entry.is_through_smoke then
			surface.SetMaterial(smoke_kill)
			surface.SetDrawColor(255, 255, 255, entry.alpha)
			surface.DrawTexturedRect(x, Y, fontspace + SPACING_TOP * 2, fontspace + SPACING_TOP * 2)
			x = x + fontspace + SPACING_TOP * 2 + SPACING_BETWEEN
		end

		if entry.is_penetrated_wall then
			surface.SetMaterial(penetrate)
			surface.SetDrawColor(255, 255, 255, entry.alpha)
			surface.DrawTexturedRect(x, Y, fontspace + SPACING_TOP * 2, fontspace + SPACING_TOP * 2)
			x = x + fontspace + SPACING_TOP * 2 + SPACING_BETWEEN
		end

		if entry.is_headshot then
			surface.SetMaterial(headshot)
			surface.SetDrawColor(255, 255, 255, entry.alpha)
			surface.DrawTexturedRect(x, Y, fontspace + SPACING_TOP * 2, fontspace + SPACING_TOP * 2)
			x = x + fontspace + SPACING_TOP * 2 + SPACING_BETWEEN
		end

		if entry.pvictim then
			surface.SetTextPos(x, Y + SPACING_TOP)
			surface.SetTextColor(entry.cvictim)
			surface.DrawText(entry.pvictim)
			x = x + entry.pvictim_w
		end

		local add = math.ceil(fontspace + SPACING_TOP * 2 + SPACING_LINES)

		Y = math.ceil(Y + add * entry.perc)
	end

	render.PopFilterMag()
	render.PopFilterMin()
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

	if is_blind and blind_by_who == attacker then
		blind_by_who = nil
		is_blind = false
	end

	local ttl = victim ~= lply and attacker ~= lply and inflictor ~= lply and TTL_DEFAULT or TTL_SELF
	local highlight = victim ~= lply and attacker == lply or inflictor == lply or blind_by_who == lply or is_assisted_by == lply

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

		highlight = highlight,

		alpha = 255,
		perc = 1,

		attacker = attacker,
		victim = victim,
		inflictor = inflictor,
		inflictor_class = inflictor_class,
		-- display_skull = not attacker or not inflictor_class or not killicon.Exists(inflictor_class),
		display_skull = not inflictor_class or not killicon.Exists(inflictor_class),
		--display_skull = true,

		color = victim == lply and Color(BACKGROUND_DEAD) or Color(BACKGROUND),
		outline = highlight and Color(OUTLINE),

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

	surface.SetFont('CSGOKillfeed')

	doset('pattacker', entry)
	doset('pvictim', entry)
	doset('pinflictor', entry)
	doset('pis_assisted_by', entry)
	doset('pblind_by_who', entry)

	if not entry.display_skull then
		local _, h = surface.GetTextSize('+')
		local desired_size = h * 1.5 + ScreenSize(SPACING_TOP)
		local _w, _h = killicon.GetSize(inflictor_class)
		local mul = 1

		if _w >= _h then
			mul = desired_size / _h
		else
			mul = desired_size / _w
		end

		entry.vec_mul = Vector(mul, mul)
		entry.mul = mul
		entry.icon_w, entry.icon_h = _w:round(), _h:round()
		entry.icon_w_mul, entry.icon_h_mul = (_w * mul):round(), (_h * mul):round()
	end

	table.insert(history, entry)
end

local function AddDeathNotice()
	return false
end

net.receive('csgo_killfeed', csgo_killfeed)
hook.Add('Think', 'CSGOKillfeed', Think)
hook.Add('HUDPaint', 'CSGOKillfeed', HUDPaint)
hook.Add('ScreenResolutionChanged', 'CSGOKillfeed', ScreenResolutionChanged)
hook.Add('AddDeathNotice', 'CSGOKillfeed', AddDeathNotice, -2)
hook.Add('DrawDeathNotice', 'CSGOKillfeed', AddDeathNotice, -2)
