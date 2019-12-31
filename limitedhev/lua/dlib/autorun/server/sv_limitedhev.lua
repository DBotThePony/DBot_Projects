
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

net.pool('LimitedHEVPower')
net.pool('LimitedHEV.SyncFlashLight')

local FLASHLIGHT = GetConVar('sv_limited_flashlight')

local function PlayerSwitchFlashlight(ply, enabled)
	if not FLASHLIGHT:GetBool() then return end
	if not enabled then return end
	if not ply:IsSuitEquipped() then return false end
	if ply:GetFlashlightCharge() == 0 then return false end
	if ply:GetFlashlightENext() > CurTime() then return false end
end

hook.Add('PlayerSwitchFlashlight', 'LimitedHEVPower', PlayerSwitchFlashlight)

local function PlayerDeath(ply)
	ply:ResetLimitedHEVPower()
	ply:ResetLimitedHEVPowerRestoreStart()
	ply:ResetLimitedHEVSuitLastPower()

	ply:ResetLimitedHEVOxygenNextChoke()
	ply:ResetLimitedHEVHPLost()
	ply:ResetLimitedHEVHPNext()
	ply:ResetFlashlightENext()

	ply:ResetFlashlightCharge()
	ply:ResetFlashlightNext()
end

hook.Add('PlayerSwitchFlashlight', 'LimitedHEVPower', PlayerSwitchFlashlight)
hook.Add('PlayerDeath', 'LimitedHEVPower', PlayerDeath)

if game.SinglePlayer() then
	timer.Simple(0, function()
		if Entity(1):IsPlayer() then
			PlayerDeath(Entity(1))
		end
	end)
end
