
-- Copyright (C) 2016-2019 DBot

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

local POWER_RESTORE_DELAY = CreateConVar('sv_limited_hev_rd', '0', CLIENT and FCVAR_REPLICATED or {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, 'Delay before starting to restore power of suit')
local POWER_RESTORE_MUL = CreateConVar('sv_limited_hev_rmul', '1', CLIENT and FCVAR_REPLICATED or {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, 'Multiplier of power restore speed')
local SPRINT_DELAY = CreateConVar('sv_limited_hev_sd', '3', CLIENT and FCVAR_REPLICATED or {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, 'Delay in seconds before player can use sprint again after running out of power to do so')

local lastPressHEV = false

local function StartCommand(ply, cmd)
	if cmd:GetButtons():band(IN_FORWARD:bor(IN_BACK)) == 0 then
		lastPressHEV = false
		return
	end

	local newHev = cmd:GetButtons():band(IN_SPEED) ~= 0
	local statusChanged = newHev ~= lastPressHEV
	lastPressHEV = newHev

	if ply.__fl_sdelay and ply.__fl_sdelay > CurTimeL() then
		cmd:SetButtons(cmd:GetButtons():band(IN_SPEED:bnot()))

		if statusChanged and CLIENT and newHev then
			ply:EmitSound('HL2Player.SprintNoPower')
		end

		return
	end

	if not ply:IsSuitEquipped() and not ply:InVehicle() then
		cmd:SetButtons(cmd:GetButtons():band(IN_SPEED:bnot()))
		return
	end

	if ply:LimitedHEVGetPower() < 10 then
		cmd:SetButtons(cmd:GetButtons():band(IN_SPEED:bnot()))
		ply.__fl_sdelay = CurTimeL() + SPRINT_DELAY:GetFloat()
		return
	end

	if cmd:GetButtons():band(IN_SPEED) ~= 0 then
		if statusChanged and CLIENT then
			ply:EmitSound('HL2Player.SprintStart')
		end

		if SERVER then
			local fldata = ply._fldata
			fldata.suit_power = (fldata.suit_power - FrameTime() * 22):clamp(0, 100)
			fldata.suit_last_frame = false
			fldata.suit_restore_start = CurTimeL() + POWER_RESTORE_DELAY:GetFloat()
		else
			__LimitedHev_SetSuitPower(ply:LimitedHEVGetPower() - FrameTime() * 22)
		end
	end
end

hook.Add('StartCommand', 'LimitedHEV', StartCommand)
