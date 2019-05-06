
--[[
Copyright (C) 2016-2019 DBotThePony


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

]]

--I belive in you Willox, fix convar replication bug!
local HEALTH_ADMIN = CreateConVar('sv_property_health_admin', '0', {FCVAR_REPLICATED, FCVAR_ARCHIVE}, 'Should Property "Health" and "Max Health" admin only')
local UNBREAKABLE_ADMIN = CreateConVar('sv_property_unbreakable_admin', '0', {FCVAR_REPLICATED, FCVAR_ARCHIVE}, 'Should Property "Make Unbreakable" admin only')

local function Can(ply)
	local wp = ply:GetWeapons()

	for k, v in pairs(wp) do
		if IsValid(v) and v:GetClass() == 'gmod_tool' then return true end
	end

	return false
end

local function DefaultFilter(self, ent, ply, tr)
	if not Can(ply) then return false end
	if ent:IsPlayer() then return false end
	if not hook.Run('CanProperty', ply, self.index, ent) then return end

	if CLIENT then
		local name, Var = debug.getlocal(2, 2)

		if name == 'tr' and istable(Var) then
			if not hook.Run('CanTool', ply, Var, self.index) then return false end
		end
	else
		if not hook.Run('CanTool', ply, tr, self.index) then return false end
		if tr.HitPos:Distance(ply:GetPos()) > 512 then return false end
	end

	return true
end

local function GetClientInfo(self, var)
	return self.CPly:GetInfo(self.index .. '_' .. var)
end

local function GetClientNumber(self, var)
	return tonumber(self:GetClientInfo(var))
end

local function DefaultAction(self, ent, tr)
	self:MsgStart()
	--DPP Strict Property Restriction Compatibility
	net.WriteEntity(ent)
	net.WriteTable(tr)
	self:MsgEnd()
end

local self = {}

self.lamp = {
	MenuLabel = 'Place/update lamp',
	Order = 1702,
	index = 'lamp',
	MenuIcon = 'icon16/lightbulb.png',

	Receive = function(self, len, ply)
		self.CPly = ply
		local ent = net.ReadEntity()
		local tr = net.ReadTable()
		tr.Entity = ent

		if not tr.Entity then return end
		if not tr.HitPos then return end
		if not self:Filter(tr.Entity, ply, tr) then return end
		if not MakeLamp then return end

		--Copypaste
		local r = math.Clamp(self:GetClientNumber("r"), 0, 255)
		local g = math.Clamp(self:GetClientNumber("g"), 0, 255)
		local b = math.Clamp(self:GetClientNumber("b"), 0, 255)
		local key = self:GetClientNumber("key")
		local texture = self:GetClientInfo("texture")
		local mdl = self:GetClientInfo("model")
		local fov = self:GetClientNumber("fov")
		local distance = self:GetClientNumber("distance")
		local bright = self:GetClientNumber("brightness")
		local toggle = self:GetClientNumber("toggle") ~= 1

		local trace = tr

		if IsValid(trace.Entity) && trace.Entity:GetClass() == "gmod_lamp" && trace.Entity:GetPlayer() == ply then
			trace.Entity:SetColor(Color(r, g, b, 255))
			trace.Entity:SetFlashlightTexture(texture)
			trace.Entity:SetLightFOV(fov)
			trace.Entity:SetDistance(distance)
			trace.Entity:SetBrightness(bright)
			trace.Entity:SetToggle(!toggle)
			trace.Entity:UpdateLight()

			numpad.Remove(trace.Entity.NumDown)
			numpad.Remove(trace.Entity.NumUp)

			trace.Entity.NumDown = numpad.OnDown(ply, key, "LampToggle", trace.Entity, 1)
			trace.Entity.NumUp = numpad.OnUp(ply, key, "LampToggle", trace.Entity, 0)

			-- For duplicator
			trace.Entity.Texture = texture
			trace.Entity.fov = fov
			trace.Entity.distance = distance
			trace.Entity.r = r
			trace.Entity.g = g
			trace.Entity.b = b
			trace.Entity.brightness	= bright
			trace.Entity.KeyDown = key

			return true
		end

		if not ply:CheckLimit('lamps') then return end

		local lamp = MakeLamp(ply, r, g, b, key, toggle, texture, mdl, fov, distance, bright, not toggle, {Pos = tr.HitPos, Angle = Angle(0, 0, 0)})

		local phys = lamp:GetPhysicsObject()

		if IsValid(phys) then
			phys:EnableMotion(false)
		end

		if lamp.CPPIGetOwner then
			if lamp:CPPIGetOwner() ~= ply then
				lamp:CPPISetOwner(ply)
			end
		end

		undo.Create("Lamp")
		undo.AddEntity(lamp)
		undo.SetPlayer(ply)
		undo.Finish()
	end,
}

self.light = {
	MenuLabel = 'Place/update light',
	Order = 1703,
	index = 'light',
	MenuIcon = 'icon16/lightbulb.png',

	Receive = function(self, len, ply)
		self.CPly = ply
		local ent = net.ReadEntity()
		local tr = net.ReadTable()
		tr.Entity = ent

		if not tr.Entity then return end
		if not tr.HitPos then return end
		if not tr.HitNormal then return end
		if not self:Filter(tr.Entity, ply, tr) then return end
		if not MakeLight then return end

		--Copypaste
		local trace = tr

		local r = math.Clamp(self:GetClientNumber("r"), 0, 255)
		local g = math.Clamp(self:GetClientNumber("g"), 0, 255)
		local b = math.Clamp(self:GetClientNumber("b"), 0, 255)
		local brght = math.Clamp(self:GetClientNumber("brightness"), 0, 255)
		local size = self:GetClientNumber("size")
		local toggle = self:GetClientNumber("toggle") ~= 1
		local key = self:GetClientNumber("key")

		if IsValid(trace.Entity) && trace.Entity:GetClass() == "gmod_light" && trace.Entity:GetPlayer() == ply then
			trace.Entity:SetColor(Color(r, g, b, 255))
			trace.Entity.r = r
			trace.Entity.g = g
			trace.Entity.b = b
			trace.Entity.Brightness = brght
			trace.Entity.Size = size

			trace.Entity:SetBrightness(brght)
			trace.Entity:SetLightSize(size)
			trace.Entity:SetToggle(!toggle)

			trace.Entity.KeyDown = key

			numpad.Remove(trace.Entity.NumDown)
			numpad.Remove(trace.Entity.NumUp)

			trace.Entity.NumDown = numpad.OnDown(ply, key, "LightToggle", trace.Entity, 1)
			trace.Entity.NumUp = numpad.OnUp(ply, key, "LightToggle", trace.Entity, 0)

			return true
		end

		if not ply:CheckLimit('lights') then return end

		local lamp = MakeLight(ply, r, g, b, brght, size, toggle, not toggle, key, {Pos = tr.HitPos + tr.HitNormal * 4, Angle = tr.HitNormal:Angle()})

		local phys = lamp:GetPhysicsObject()

		if IsValid(phys) then
			phys:EnableMotion(false)
		end

		if lamp.CPPIGetOwner then
			if lamp:CPPIGetOwner() ~= ply then
				lamp:CPPISetOwner(ply)
			end
		end

		local length = math.Clamp(self:GetClientNumber("ropelength"), 4, 1024)
		local material = self:GetClientInfo("ropematerial")

		local LPos1 = Vector( 0, 0, 5 )
		local LPos2 = trace.Entity:WorldToLocal( trace.HitPos )

		if IsValid(trace.Entity) then
			local phys = trace.Entity:GetPhysicsObjectNum(trace.PhysicsBone)
			if IsValid(phys)  then
				LPos2 = phys:WorldToLocal(trace.HitPos)
			end
		end

		local constraint, rope = constraint.Rope(lamp, trace.Entity, 0, trace.PhysicsBone, LPos1, LPos2, 0, length, 0, 1, material)

		undo.Create("Light")
		undo.AddEntity(lamp)
		undo.AddEntity(rope)
		undo.AddEntity(constraint)
		undo.SetPlayer(ply)
		undo.Finish()
	end,
}

self.hoverball = {
	MenuLabel = 'Place/update hoverball',
	Order = 1704,
	index = 'hoverball',
	MenuIcon = 'icon16/sport_8ball.png',

	Receive = function(self, len, ply)
		self.CPly = ply
		local ent = net.ReadEntity()
		local tr = net.ReadTable()
		tr.Entity = ent

		if not tr.Entity then return end
		if not tr.HitPos then return end
		if not tr.HitNormal then return end
		if not self:Filter(tr.Entity, ply, tr) then return end
		if not MakeHoverBall then return end

		local model = self:GetClientInfo("model")
		local key_d = self:GetClientNumber("keydn")
		local key_u = self:GetClientNumber("keyup")
		local speed = self:GetClientNumber("speed")
		local strength = math.Clamp(self:GetClientNumber("strength"), 0.1, 20)
		local resistance = math.Clamp(self:GetClientNumber("resistance"), 0, 20)

		--Update
		if IsValid(tr.Entity) and tr.Entity:GetClass() == "gmod_hoverball" and tr.Entity.pl == ply then
			tr.Entity:SetSpeed(speed)
			tr.Entity:SetAirResistance(resistance)
			tr.Entity:SetStrength(strength)

			numpad.Remove(tr.Entity.NumDown)
			numpad.Remove(tr.Entity.NumUp)
			numpad.Remove(tr.Entity.NumBackDown)
			numpad.Remove(tr.Entity.NumBackUp)

			tr.Entity.NumDown = numpad.OnDown(ply, key_u, "Hoverball_Up", tr.Entity, true)
			tr.Entity.NumUp = numpad.OnUp(ply, key_u, "Hoverball_Up", tr.Entity, false )

			tr.Entity.NumBackDown = numpad.OnDown(ply, key_d, "Hoverball_Down", tr.Entity, true)
			tr.Entity.NumBackUp = numpad.OnUp(ply, key_d, "Hoverball_Down", tr.Entity, false)

			tr.Entity.key_u = key_u
			tr.Entity.key_d = key_d
			tr.Entity.speed = speed
			tr.Entity.strength = strength
			tr.Entity.resistance	= resistance

			return
		end

		if not ply:CheckLimit('hoverballs') then return end

		if not util.IsValidModel(model) then return false end
		if not util.IsValidProp(model) then return false end

		local ball = MakeHoverBall(ply, tr.HitPos, key_d, key_u, speed, resistance, strength, model)

		if ball.CPPIGetOwner then
			if ball:CPPIGetOwner() ~= ply then
				ball:CPPISetOwner(ply)
			end
		end

		local CurPos = ball:GetPos()
		local NearestPoint = ball:NearestPoint(CurPos - tr.HitNormal * 512)
		local Offset = CurPos - NearestPoint

		ball:SetPos(tr.HitPos + Offset)

		local const, nocollide

		-- Don't weld to world
		if tr.Entity ~= NULL and not tr.Entity:IsWorld() then
			const = constraint.Weld(ball, tr.Entity, 0, tr.PhysicsBone, 0, 0, true)

			if IsValid(ball:GetPhysicsObject()) then ball:GetPhysicsObject():EnableCollisions(false) end
			ball.nocollide = true
		end

		undo.Create("HoverBall")
		undo.AddEntity(ball)
		undo.AddEntity(const)
		undo.SetPlayer(ply)
		undo.Finish()

		ply:AddCleanup("hoverballs", ball)
		ply:AddCleanup("hoverballs", const)
		ply:AddCleanup("hoverballs", nocollide)
	end,
}

self.thruster = {
	MenuLabel = 'Place/update thruster',
	Order = 1705,
	index = 'thruster',
	MenuIcon = 'icon16/lightning.png',

	Receive = function(self, len, ply)
		self.CPly = ply
		local ent = net.ReadEntity()
		local tr = net.ReadTable()
		tr.Entity = ent

		if not tr.Entity then return end
		if not tr.HitPos then return end
		if not tr.HitNormal then return end
		if not self:Filter(tr.Entity, ply, tr) then return end
		if not MakeThruster then return end
		local trace = tr

		local force = math.Clamp(self:GetClientNumber("force"), 0, 1E35)
		local model = self:GetClientInfo("model")
		local key = self:GetClientNumber("keygroup")
		local key_bk = self:GetClientNumber("keygroup_back")
		local toggle = self:GetClientNumber("toggle")
		local collision = self:GetClientNumber("collision")
		local effect = self:GetClientInfo("effect")
		local damageable = self:GetClientNumber("damageable")
		local soundname = self:GetClientInfo("soundname")

		if IsValid(trace.Entity) and trace.Entity:GetClass() == "gmod_thruster" and trace.Entity.pl == ply then
			trace.Entity:SetForce(force)
			trace.Entity:SetEffect(effect)
			trace.Entity:SetToggle(toggle == 1)
			trace.Entity.ActivateOnDamage = damageable == 1
			trace.Entity:SetSound(soundname)

			numpad.Remove(trace.Entity.NumDown)
			numpad.Remove(trace.Entity.NumUp)
			numpad.Remove(trace.Entity.NumBackDown)
			numpad.Remove(trace.Entity.NumBackUp)

			trace.Entity.NumDown = numpad.OnDown(ply, key, "Thruster_On", trace.Entity, 1)
			trace.Entity.NumUp = numpad.OnUp(ply, key, "Thruster_Off", trace.Entity, 1)

			trace.Entity.NumBackDown = numpad.OnDown(ply, key_bk, "Thruster_On", trace.Entity, -1)
			trace.Entity.NumBackUp = numpad.OnUp(ply, key_bk, "Thruster_Off", trace.Entity, -1)

			trace.Entity.key = key
			trace.Entity.key_bk = key_bk
			trace.Entity.force = force
			trace.Entity.toggle = toggle
			trace.Entity.effect = effect
			trace.Entity.damageable = damageable
			return
		end

		if not ply:CheckLimit("thrusters") then return false end

		if not util.IsValidModel(model) then return false end
		if not util.IsValidProp(model) then return false end

		local Ang = trace.HitNormal:Angle()
		Ang.pitch = Ang.pitch + 90

		local thruster = MakeThruster(ply, model, Ang, trace.HitPos, key, key_bk, force, toggle, effect, damageable, soundname)

		local min = thruster:OBBMins()
		thruster:SetPos(trace.HitPos - trace.HitNormal * min.z)

		local const

		-- Don't weld to world
		if IsValid(trace.Entity) then
			const = constraint.Weld(thruster, trace.Entity, 0, trace.PhysicsBone, 0, collision == 0, true)

			-- Don't disable collision if it's not attached to anything
			if collision == 0 then
				thruster:GetPhysicsObject():EnableCollisions(false)
				thruster.nocollide = true
			end
		end

		undo.Create("Thruster")
			undo.AddEntity(thruster)
			undo.AddEntity(const)
			undo.SetPlayer(ply)
		undo.Finish()

		ply:AddCleanup("thrusters", thruster)
		ply:AddCleanup("thrusters", const)
	end,
}

self.freeze = {
	MenuLabel = 'Freeze',
	Order = 1601,
	MenuIcon = 'icon16/link.png',

	Filter = function(self, ent, ply)
		if ent:IsPlayer() then return false end
		if SERVER and not IsValid(ent:GetPhysicsObject()) then return false end
		if SERVER and not ent:GetPhysicsObject():IsMotionEnabled() then return false end
		if CLIENT and ent:GetNWBool('ExtraProperties.Frozen') then return false end
		if not hook.Run('CanProperty', ply, 'freeze', ent) then return false end

		return true
	end,

	Action = function(self, ent, tr)
		self:MsgStart()
		net.WriteEntity(ent)
		self:MsgEnd()
	end,

	Receive = function(self, len, ply)
		local ent = net.ReadEntity()
		if not self:Filter(ent, ply) then return end
		ent:GetPhysicsObject():EnableMotion(false)
		ent:SetNWBool('ExtraProperties.Frozen', true)
	end,
}

self.unfreeze = {
	MenuLabel = 'Unfreeze',
	Order = 1602,
	MenuIcon = 'icon16/link_break.png',

	Filter = function(self, ent, ply)
		if ent:IsPlayer() then return false end
		if SERVER and not IsValid(ent:GetPhysicsObject()) then return false end
		if SERVER and ent:GetPhysicsObject():IsMotionEnabled() then return false end
		if CLIENT and not ent:GetNWBool('ExtraProperties.Frozen') then return false end
		if not hook.Run('CanProperty', ply, 'unfreeze', ent) then return false end

		return true
	end,

	Action = function(self, ent, tr)
		self:MsgStart()
		net.WriteEntity(ent)
		self:MsgEnd()
	end,

	Receive = function(self, len, ply)
		local ent = net.ReadEntity()
		if not self:Filter(ent, ply) then return end
		ent:GetPhysicsObject():EnableMotion(true)
		ent:SetNWBool('ExtraProperties.Frozen', false)
	end,
}

self.unbreakable = {
	MenuLabel = 'Make unbreakable',
	Order = 1603,
	MenuIcon = 'icon16/shield.png',

	Filter = function(self, ent, ply)
		if UNBREAKABLE_ADMIN:GetBool() and not ply:IsAdmin() then return false end
		if ent:GetClass() ~= 'prop_physics' then return end
		if not hook.Run('CanProperty', ply, 'unbreakable', ent) then return false end

		return true
	end,

	Action = function(self, ent, tr)
		self:MsgStart()
		net.WriteEntity(ent)
		self:MsgEnd()
	end,

	Receive = function(self, len, ply)
		local ent = net.ReadEntity()
		if not self:Filter(ent, ply) then return end

		--Don't know anything better
		local id = 'zUnbreakable_' .. ent:EntIndex()
		hook.Add('EntityTakeDamage', id, function(ent1, dmg)
			if not IsValid(ent) then
				hook.Remove('EntityTakeDamage', id)
				return
			end

			if ent1 ~= ent then return end
			dmg:SetDamage(0)
		end, 2)
	end,
}

self.sethealth = {
	MenuLabel = 'Set health',
	Order = 1604,
	MenuIcon = 'icon16/heart.png',

	Filter = function(self, ent, ply)
		if HEALTH_ADMIN:GetBool() and not ply:IsAdmin() then return false end
		if ent:IsPlayer() then return false end
		if not hook.Run('CanProperty', ply, 'sethealth', ent) then return false end

		return true
	end,

	MenuOpen = function(self, menu, ent, tr)
		local SubMenu = menu:AddSubMenu()
		local ply = LocalPlayer()

		for i = 50, 400, 50 do
			local Pnl = SubMenu:AddOption(i .. ' health', function()
				self:MsgStart()
				net.WriteEntity(ent)
				net.WriteUInt(i, 32)
				self:MsgEnd()
			end)

			Pnl:SetIcon('icon16/heart.png')
		end
	end,

	Action = function(self, ent, tr)
		local pnl = Derma_StringRequest(
			'Set Health',
			'Set the health of entity ' .. tostring(ent) .. ' to...\nCurrent: ' .. ent:Health(),
			tostring(ent:Health()),
			function(text)
				self:MsgStart()
				net.WriteEntity(ent)
				net.WriteUInt(tonumber(text), 32)
				self:MsgEnd()
			end,
			function() end
		)
	end,

	Receive = function(self, len, ply)
		local ent = net.ReadEntity()
		if not self:Filter(ent, ply) then return end

		local hp = net.ReadUInt(32)
		if not hp then return end
		ent:SetHealth(hp)
	end,
}

self.setmaxhealth = {
	MenuLabel = 'Set max health',
	Order = 1605,
	MenuIcon = 'icon16/heart_add.png',

	Filter = function(self, ent, ply)
		if HEALTH_ADMIN:GetBool() and not ply:IsAdmin() then return end
		if ent:IsPlayer() then return false end
		if not hook.Run('CanProperty', ply, 'setmaxhealth', ent) then return false end

		return true
	end,

	MenuOpen = function(self, menu, ent, tr)
		local SubMenu = menu:AddSubMenu()
		local ply = LocalPlayer()

		for i = 50, 400, 50 do
			local Pnl = SubMenu:AddOption(i .. ' health', function()
				self:MsgStart()
				net.WriteEntity(ent)
				net.WriteUInt(i, 32)
				self:MsgEnd()
			end)

			Pnl:SetIcon('icon16/heart_add.png')
		end
	end,

	Action = function(self, ent, tr)
		Derma_StringRequest(
			'Set Max Health',
			'Set the max health of entity ' .. tostring(ent) .. ' to...\nCurrent: ' .. ent:Health(),
			tostring(ent:GetMaxHealth()),
			function(text)
				self:MsgStart()
				net.WriteEntity(ent)
				net.WriteUInt(tonumber(text), 32)
				self:MsgEnd()
			end,
			function() end
		)
	end,

	Receive = function(self, len, ply)
		local ent = net.ReadEntity()
		if not self:Filter(ent, ply) then return end

		local hp = net.ReadUInt(32)
		if not hp then return end
		ent:SetMaxHealth(hp)
	end,
}

for k, v in pairs(self) do
	v.Filter = v.Filter or DefaultFilter
	v.Action = v.Action or DefaultAction
	v.GetClientInfo = v.GetClientInfo or GetClientInfo
	v.GetClientNumber = v.GetClientNumber or GetClientNumber
	properties.Add(k, v)
end
