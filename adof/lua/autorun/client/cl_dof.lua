
--[[
Copyright (C) 2016-2017 DBot

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
]]

--ADOF - Advanced Depth of Field

local ENABLE = CreateClientConVar('adof_enable', '1', true, false, 'Enable ADOF. Needs beefy videocard!')
local DRAW_ON_SCREEN = CreateClientConVar('adof_screen', '1', true, false, 'Draw ADOF on Screen')
local ADOF_PASSES = CreateClientConVar('adof_passes', '16', true, false, 'ADOF Passes')
local ALWAYS_DOF = CreateClientConVar('adof_always', '1', true, false, 'Always draw DoF')
local DRAW_MODE = CreateClientConVar('adof_mode', '0', true, false, 'Draw Mode - 0 as Renderable, 1 as effect')
local ENABLE_BOKEN = CreateClientConVar('adof_boken', '0', true, false, 'Enable Boken DOF. Breaks things!')

ADOF = ADOF or {}
ADOF.Ents = ADOF.Ents or {}

ADOF.SPACING = 50
ADOF.OFFSET = 1000
ADOF.REAL_NUM_DOF_NODES = 16
ADOF.NUM_DOF_NODES = 16
ADOF.Render = true
ADOF.Max = 6000
ADOF.Critical = ADOF.Max * 0.5

local function IsCurrVehicle(ent)
	local ply = LocalPlayer()
	
	return IsValid(ent) and 
		ent:IsVehicle() and 
		ply:InVehicle() and 
		IsValid(ply:GetVehicle()) and 
		(ply:GetVehicle() == ent or 
		ply:GetVehicle():GetParent() == ent)
end

local blur_mat = Material('pp/bokehblur')
local fmat = CreateMaterial('ADOF_Material', 'Refract', {
	['$model'] = '1',
 	["$normalmap"] = "effects/flat_normal",
 	["$refractamount"] = "0",
	["$vertexalpha"] = "1",
	["$vertexcolor"] = "1",
	["$translucent"] = "1",
	["$forcerefract"] = '1',
 	["$bluramount"] = "1",
	["$nofog"] = "1",
})

local TotalRenderTime = 0
local NextCleanup = 0
local Hits = 0
local LastHit = 0

local SPACE, SPACING = 0, 0
local ShouldDrawOnScreen = false

local Rendering = false

local function DrawOnScreen()
	if not ADOF.Render then return end
	if not DRAW_ON_SCREEN:GetBool() then return end
	if not ShouldDrawOnScreen then return end
	if not system.HasFocus() then return end
	surface.SetDrawColor(255, 255, 255, 255)
	surface.SetMaterial(fmat)
	
	local W, H = ScrW(), ScrH()
	
	local toupdate = LocalPlayer():WaterLevel() < 1
	for i=0, ADOF.NUM_DOF_NODES do
		if toupdate then
			render.UpdateScreenEffectTexture()
		else
			render.UpdateRefractTexture()
		end
		surface.DrawTexturedRect(0, H / 2 + SPACE + i * SPACING, W, H)
		surface.DrawTexturedRect(0, 0, W, H / 2 - SPACE - i * SPACING)
	end
end

local function HUDPaintBackground()
	DrawOnScreen()
	Rendering = true
end

local function PostDrawHUD()
	if Rendering then Rendering = false return end
	DrawOnScreen()
end

-- Note: UpdateScreenEffectTexture fucks up the water, RefractTexture is lower quality
local function Render()
	if not ADOF.Render then return end
	if bDrawingDepth or bDrawingSkybox then return end
	if not system.HasFocus() then return end
	
	if not ALWAYS_DOF:GetBool() and ADOF.OFFSET == ADOF.Max then return end
	local ply = LocalPlayer()
	
	local pos = ply:EyePos()
	local langles = EyeAngles()
	local fwd = langles:Forward()
	
	if ply:GetViewEntity() ~= ply then
		pos = ply:GetViewEntity():GetPos()
		fwd = ply:GetViewEntity():GetForward()
	end
	
	local toupdate = ply:WaterLevel() < 1
	
	local CurrentAlpha = 0.1
	
	render.SetMaterial(fmat)
	
	for i=0, ADOF.NUM_DOF_NODES do
		if toupdate then
			render.UpdateScreenEffectTexture()
		else
			render.UpdateRefractTexture()
		end
		
		local npos = pos + fwd * ADOF.SPACING * i + fwd * ADOF.OFFSET
		local SpriteSize = (ADOF.SPACING * i + ADOF.OFFSET) * 8
		
		if pos:Distance(npos) > ADOF.Max * 2 then break end
		
		CurrentAlpha = CurrentAlpha + 0.1
		
		render.DrawSprite(npos, SpriteSize, SpriteSize, Color( 255, 255, 255, CurrentAlpha * 255 ) )
	end
end

local SHOULD_DRAW_BOKEN = false
local BOKEN_FOCUS = 0.1
local BOKEN_FOCUS_D = 0.1
local BOKEN_FORCE = 1
local BOKEN_STEP = 0.03

local function RenderScreenspaceEffects()
	if not ADOF.Render then return end
	if not SHOULD_DRAW_BOKEN then return end
	if not ENABLE_BOKEN:GetBool() then return end
	if not system.HasFocus() then return end
	
	local ply = LocalPlayer()
	if ply:WaterLevel() > 0 then return end
	
	render.UpdateScreenEffectTexture()
	
	blur_mat:SetTexture("$BASETEXTURE", render.GetScreenEffectTexture())
	blur_mat:SetTexture("$DEPTHTEXTURE", render.GetResolvedFullFrameDepth())
	
	blur_mat:SetFloat("$size", BOKEN_FOCUS * 3)
	blur_mat:SetFloat("$focus", BOKEN_FOCUS)
	blur_mat:SetFloat("$focusradius", 2 - BOKEN_FORCE * 2)
	
	render.SetMaterial(blur_mat)
	render.DrawScreenQuad()
end

local function NeedsDepthPass()
	if not ADOF.Render then return end
	if not SHOULD_DRAW_BOKEN then return end
	if not ENABLE_BOKEN:GetBool() then return end
	
	return true
end

hook.Add('PostDrawTranslucentRenderables', 'ADOF.Draw', function(a, b)
	if a or b then return end
	if not DRAW_MODE:GetBool() then Render() end
end, 2) --Lower priority

hook.Add('PreDrawEffects', 'ADOF.Draw', function()
	if DRAW_MODE:GetBool() then Render() end
end, 2) --Lower priority

hook.Add('RenderScreenspaceEffects', 'ADOF.Draw', RenderScreenspaceEffects)
hook.Add('HUDPaintBackground', 'ADOF.Draw', HUDPaintBackground)
hook.Add('PostDrawHUD', 'ADOF.Draw', PostDrawHUD)
hook.Add('NeedsDepthPass', 'ADOF.Draw', NeedsDepthPass)

local last = 0
local lastdist = 0
local LastHitWasEntity = false
local EntityHitCooldown = 0
local FocusCooldown = 0
local Focused = false
local mult = 5
local BokenCooldown = 0

local function Change(old, new)
	local delta = new - old
	if delta >= 0 then
		return math.Clamp(old + delta^(1/2), old, new)
	else
		return math.Clamp(old - (-delta)^(1/2), new, old)
	end
end

local function ShouldEnabledScreen()
	if pace and pace.IsActive and pace.IsActive() then return false end
	return true
end

local function pointInsideBox(point, mins, maxs)
	return
		mins.x < point.x and point.x < maxs.x and
		mins.y < point.y and point.y < maxs.y and
		mins.z < point.z and point.z < maxs.z
end

local function Think()
	if not ENABLE:GetBool() then
		ADOF.Render = false
		return
	else
		ADOF.Render = true
	end
	
	if not system.HasFocus() then return end
	
	local ply = LocalPlayer()
	local obs = ply:GetObserverTarget()
	local observer = false
	
	if IsValid(obs) and obs:IsPlayer() then
		ply = obs
		observer = true
	end
	
	local trace = {}
	
	local eye, langles, ignoreEnts
	
	if observer then
		eye = ply:EyePos()
		langles = ply:EyeAngles()
	else
		if not ply:ShouldDrawLocalPlayer() then
			eye = ply:EyePos()
			langles = ply:EyeAngles()
			
			if ply:InVehicle() then
				langles = ply:GetVehicle():GetAngles() + langles
			end
		else
			eye = EyePos()
			langles = EyeAngles()
			ignoreEnts = true
		end
	end
	
	local FILTER = {}
	
	trace.start = eye
	trace.endpos = langles:Forward() * 300 + eye
	trace.filter = function(ent)
		if ent == ply then return false end
		if ent:GetClass() == 'func_breakable_surf' then return false end
		if FILTER[ent] then return false end
		
		if ignoreEnts and (pointInsideBox(eye, ent:WorldSpaceAABB()) or eye:DistToSqr(ent:GetPos()) < 400) then return false end
		
		return true
	end
	
	if ply:InVehicle() then
		if IsValid(ply:GetVehicle()) then
			FILTER[ply:GetVehicle()] = true
			
			if IsValid(ply:GetVehicle():GetParent()) then
				FILTER[ply:GetVehicle():GetParent()] = true
			end
		end
	end
	
	for _, ent in pairs(ents.FindInSphere(eye, 32)) do --Finding ents what are parented to player (player seats on player, etc.)
		if ent:GetParent() == ply then
			FILTER[ent] = true
		end
		
		if ent:IsPlayer() and ent ~= ply and ent:InVehicle() and IsValid(ent:GetVehicle()) and ent:GetVehicle():GetParent() == ply then
			FILTER[ent] = true
		end
	end
	
	local tr = util.TraceLine(trace)
	
	local dist = tr.HitPos:Distance(ply:GetPos())
	
	if IsValid(tr.Entity) then 
		if tr.Entity:IsPlayer() and langles.p > 20 and tr.Entity:GetPos().z - LocalPlayer():GetPos().z < -30 then --We are looking at player when standing on him
			dist = dist*4
		elseif langles.p > 25 then --Small thing
			dist = dist*2
		end
		
		if tr.Entity:IsPlayer() then dist = math.max(dist, 50) end
	end
	
	if ((IsValid(tr.Entity) and dist < 300) or dist < 200) and FocusCooldown < CurTime() then
		if not Focused then
			FocusCooldown = CurTime() + 0.3
			Focused = true
		end
		local offset = 40
		
		last = CurTime() + 0.4
		
		if not IsValid(tr.Entity) then
			offset = 20
			
			if ShouldDrawOnScreen then
				SPACING = SPACING * 1.05
				SPACE = SPACE * 1.05
				
				if SPACE > 2000 then
					ShouldDrawOnScreen = false
				end
			end
		else
			LastHitWasEntity = true
			EntityHitCooldown = CurTime() + 1
			
			local dist = dist / 2
			if tr.Entity:IsPlayer() and dist < 60 and ShouldEnabledScreen() then
				if tr.Entity:InVehicle() then dist = dist * .75 end
				SPACE = Change(SPACE, math.max(dist * 6, 100))
				SPACING = Change(SPACING, dist / 3)
				ShouldDrawOnScreen = true
			else
				if ShouldDrawOnScreen then
					SPACING = SPACING * 1.05
					SPACE = SPACE * 1.05
					
					if SPACE > 2000 then
						ShouldDrawOnScreen = false
					end
				end
			end
		end
		
		if not (ADOF.OFFSET - ADOF.OFFSET * FrameTime()*mult < dist + dist - offset and ADOF.OFFSET + ADOF.OFFSET * FrameTime() * mult > dist + dist - offset) then
			if ADOF.OFFSET - ADOF.OFFSET * FrameTime() * mult < dist + dist - offset then
				ADOF.OFFSET = math.max(ADOF.OFFSET + ADOF.OFFSET * FrameTime() * mult, dist + dist - offset)
			else
				ADOF.OFFSET = math.max(ADOF.OFFSET - ADOF.OFFSET * FrameTime() * mult, dist + dist - offset)
			end
		end
		
		if ENABLE_BOKEN:GetBool() then
			if dist < 150 and (not IsValid(tr.Entity) or not (tr.Entity:IsPlayer() or tr.Entity:GetClass() == 'prop_door_rotating')) then --We are looking at the thing, not player
				SHOULD_DRAW_BOKEN = true
				BOKEN_FOCUS = math.Clamp(0.6 - dist / 150, 0,1)
				BokenCooldown = CurTime() + 2
				BOKEN_FORCE = math.Clamp(BOKEN_FORCE + BOKEN_STEP * (FrameTime() * 66), 0,1)
			elseif dist < 150 and IsValid(tr.Entity) then
				SHOULD_DRAW_BOKEN = true
				BOKEN_FOCUS = math.Clamp(0.5 - dist / 90, 0,1)
				BokenCooldown = CurTime() + 2
				BOKEN_FORCE = math.Clamp(BOKEN_FORCE + BOKEN_STEP * (FrameTime() * 66), 0,1)
			else --We are too far or not looking at anything
				if BokenCooldown < CurTime() then
					SHOULD_DRAW_BOKEN = false
					BOKEN_FOCUS = 0.1
				else
					BOKEN_FORCE = math.Clamp(BOKEN_FORCE - BOKEN_STEP * (FrameTime() * 66), 0,1)
				end
			end
		end
		
		if not IsValid(tr.Entity) and LastHitWasEntity and EntityHitCooldown < CurTime() then
			lastdist = dist
			LastHitWasEntity = false
		elseif not IsValid(tr.Entity) and not LastHitWasEntity then
			lastdist = dist
		elseif IsValid(tr.Entity) then
			lastdist = dist
		end
		
		ADOF.SPACING = Change(ADOF.SPACING, ((lastdist - 40)^2)/6)
	elseif last < CurTime() then
		ADOF.OFFSET = math.min(ADOF.OFFSET + 80 * (FrameTime() * 66), ADOF.Max)
		ADOF.SPACING = math.min(ADOF.SPACING + 80 * (FrameTime() * 66), 400)
		LastHitWasEntity = false
		
		if ENABLE_BOKEN:GetBool() then
			if ADOF.OFFSET > 200 and BokenCooldown < CurTime() then
				SHOULD_DRAW_BOKEN = false
				BOKEN_FOCUS = 0.1
				BOKEN_FORCE = math.Clamp(BOKEN_FORCE - BOKEN_STEP * (FrameTime() * 66), 0,1)
			elseif BokenCooldown > CurTime() and ADOF.OFFSET > 200 then
				BOKEN_FORCE = math.Clamp(BOKEN_FORCE - BOKEN_STEP * (FrameTime() * 66), 0,1)
			end
		end
		
		if ShouldDrawOnScreen then
			SPACING = SPACING * 1.2
			SPACE = SPACE * 1.2
			
			if SPACE > 2000 then
				ShouldDrawOnScreen = false
			end
		end
		
		if Focused then
			FocusCooldown = 0
			Focused = false
		end
	end
	
	if ADOF.OFFSET > ADOF.Critical then
		local delta = (ADOF.OFFSET - ADOF.Critical) / (ADOF.Max - ADOF.Critical)
		local MAX = ADOF_PASSES:GetInt()
		local count = math.ceil(delta * MAX / 1.2)
		ADOF.NUM_DOF_NODES = MAX - count
	else
		ADOF.NUM_DOF_NODES = ADOF_PASSES:GetInt()
	end
end

hook.Add("Think", "ADOF", Think)
