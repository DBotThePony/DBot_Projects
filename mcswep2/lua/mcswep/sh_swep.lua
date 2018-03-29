
--[[
Copyright (C) 2016-2018 DBot

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

local mc = MCSWEP2

local SWEP = {}
SWEP.Author = 'DBot'
SWEP.Category = 'Other'
SWEP.Spawnable = false
SWEP.PrintName = 'Minecraft SWEP v2'
SWEP.UseHands = false
SWEP.WorldModel = 'models/props_junk/cardboard_box004a.mdl'
SWEP.ViewModel = 'models/weapons/c_arms.mdl'
SWEP.DrawAmmo = false
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Spawnable = true
SWEP.Category = 'MCSWEP2'

SWEP.Primary = {}
SWEP.Primary.Ammo = 'none'
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Secondary = SWEP.Primary

function SWEP:Initialize()
	if CLIENT then
		self.ClientsideModel = ClientsideModel('models/mcmodelpack/blocks/bedrock.mdl', RENDERGROUP_BOTH)
		local ent = self.ClientsideModel
		ent.MODEL = 'models/mcmodelpack/blocks/bedrock.mdl'
		ent:SetNoDraw(true)
	end
end

function SWEP:Deploy()
	if self:GetOwner():IsPlayer() then
		self:GetOwner():DrawViewModel(false)
	end

	return true
end

function SWEP:Holster()
	if self:GetOwner():IsPlayer() then
		self:GetOwner():DrawViewModel(true)
	end

	return true
end

function SWEP:PreDrawViewModel(vm)
    return true
end

function SWEP:GetMaxDistance()
	return 256
end

function SWEP:ClientNumber(cvar, default)
	local ply = self:GetOwner()

	if not IsValid(ply) then return default end
	if not ply:IsPlayer() then return default end

	local num

	if CLIENT and ply == LocalPlayer() then
		local i = 'CVar_' .. cvar
		self[i] = self[i] or GetConVar(cvar)

		num = self[i]:GetFloat() or default
	else
		num = tonumber(ply:GetInfo(cvar)) or default
	end

	return num
end

function SWEP:GetBlockID()
	local num = self:ClientNumber('cl_mc_blockid', MCSWEP2.DEFAULT_ID)
	num = math.floor(num)
	num = MCSWEP2.ValidateBlockID(num)

	return num
end

function SWEP:GetBlockSkin()
	local num = self:ClientNumber('cl_mc_blockskin', MCSWEP2.DEFAULT_SKIN)
	num = MCSWEP2.ValidateBlockSkin(self:GetBlockID(), num)

	return num
end

local function PosZ(pos1, pos2)
	return pos1.z - pos2.z
end

local AngleDir = mc.AngleDir

function SWEP:Trace()
	local ply = self:GetOwner()
	local eyes = ply:EyePos()
	local ang = ply:EyeAngles()

	local tr = util.TraceLine{
		start = eyes,
		endpos = eyes + ang:Forward() * self:GetMaxDistance(),
		filter = ply,
	}

	local ent = tr.Entity
	local flip = false
	local direction = mc.ROTATE_SOUTH

	if IsValid(ent) and ent.IsMCBlock then
		local epos = ent:GetPos()
		local height = ent.GetBlockHeight and ent:GetBlockHeight() or 1
		local width = ent.GetBlockWidth and ent:GetBlockWidth() or 1

		if ent:GetFlip() then
			epos.z = epos.z - mc.STEP
		end

		local realpos = tr.HitPos

		if math.abs(PosZ(tr.HitPos, tr.HitNormal * 3 + tr.HitPos)) > 1 then
			tr.HitPos = epos + tr.HitNormal * MCSWEP2.STEP / 2 - (tr.HitNormal * (1 - height) * mc.STEP)
		else
			tr.HitPos = epos + tr.HitNormal * MCSWEP2.STEP / 2 - (tr.HitNormal * (1 - width) * mc.STEP)
		end

		local h = PosZ(tr.HitPos, epos)

		local rh = PosZ(realpos, epos)
		flip = (rh >= MCSWEP2.STEP / 2 or h <= - MCSWEP2.STEP / 2) and not ((rh + 1) >= MCSWEP2.STEP)

		if ((h + 1) >= MCSWEP2.STEP / 2 or tobool(self:ClientNumber('cl_mc_rotate_ang', 1))) and not self:GetData().rotateblock then
			direction = AngleDir(math.NormalizeAngle((ply:GetPos() - realpos):Angle().y))
		else
			direction = AngleDir(tr.HitNormal:Angle().y)
		end
	else
		tr.HitPos = tr.HitPos - tr.HitNormal * 5

		direction = AngleDir(math.NormalizeAngle((ply:GetPos() - tr.HitPos):Angle().y))
	end

	return tr, flip, direction
end

function SWEP:GetData()
	return MCSWEP2.GetBlockData(self:GetBlockID())
end

local Mins, Maxs = Vector(-MCSWEP2.STEP / 2, -MCSWEP2.STEP / 2, 0), Vector(MCSWEP2.STEP / 2, MCSWEP2.STEP / 2, MCSWEP2.STEP)

function SWEP:PlaceBlock(pos, flip, direction)
	if CLIENT then return end

	direction = direction or mc.ROTATE_SOUTH

	local tr = util.TraceHull{
		start = pos + Vector(0, 0, 3),
		endpos = pos + Vector(0, 0, MCSWEP2.STEP / 2),
		mins = Mins,
		maxs = Maxs,
		ignoreworld = true,
		filter = function(ent)
			if ent.IsMCBlock then return false end
			return true
		end
	}

	if tr.Hit and IsValid(tr.Entity) then return false end

	local ply = self:GetOwner()
	local bclass = self:GetData().class
	local bid = self:GetBlockID()

	if not game.SinglePlayer() then
		if #MCSWEP2.GetActiveBlocks() >= MCSWEP2.mcswep2_blocklimit:GetInt() then
			ply:ChatPrint('[MCSWEP2] Reached placed blocks limit (' .. MCSWEP2.mcswep2_blocklimit:GetInt() .. ')')
			return false
		end

		if #MCSWEP2.GetActiveBlocksByPlayer(ply) >= MCSWEP2.mcswep2_playerlimit:GetInt() then
			ply:ChatPrint('[MCSWEP2] Reached placed blocks limit for one player (' .. MCSWEP2.mcswep2_playerlimit:GetInt() .. ')')
			return false
		end
	end

	local bdata = MCSWEP2.GetBlockByID(bid)

	if not game.SinglePlayer() and MCSWEP2.IsBlockBlacklisted(bdata.name) then
		ply:ChatPrint('[MCSWEP2] This block is blacklisted by server owner, sorry!')
		return false
	end

	local ent = ents.Create(bclass)
	ent:SetPos(pos)
	ent:SetupOwner(ply)

	ent:Spawn()
	ent:Activate()
	ent:FixedMove()

	ent:InitializeBlockID(bid, false, true)

	ent:SetRotate(direction)
	ent:SetFlip(flip)
	ent:PreformRotate()
	ent:PreformFlip()

	ent:TriggerUpdate()
	ent:BlockUpdate()

	ent:PlayPlaceSound()

	ent:SetSkin(self:GetBlockSkin())

	undo.Create('MCBlock')
	undo.SetPlayer(ply)
	undo.AddEntity(ent)
	undo.Finish()

	return true
end

function SWEP:DrawHUD()
	local ent = self.ClientsideModel
	if not IsValid(ent) then return end

	local tr, flip, direction = self:Trace()
	if not tr.Hit then return end

	cam.Start3D()

	local mid = tr.HitPos + tr.HitNormal * MCSWEP2.STEP / 2
	local endpos = MCSWEP2.SharpVector(self:FindNicePlace(tr.HitPos + tr.HitNormal * MCSWEP2.STEP / 2))

	if MCSWEP2.DRAW_DIRECTION:GetBool() then
		render.DrawLine(tr.HitPos, mid, color_white)
		render.DrawLine(mid, endpos, color_white)
	end

	if MCSWEP2.DRAW_BLOCKPLACE:GetBool() then
		local model = mc.GetBlockModel(self:GetBlockID())
		local skin = self:GetBlockSkin()

		if ent.MODEL ~= model then
			ent.MODEL = model
			ent:SetModel(model)
		end

		if ent.SKIN ~= skin then
			ent.SKIN = skin
			ent:SetSkin(skin)
		end

		local FinalAngle = Angle(0, 0, 0)
		local FinalPos = endpos

		if self:GetData().rotate then
			FinalAngle.y = mc.GetRotateAngle(direction)
			FinalPos = FinalPos + mc.GetSideVector()
		end

		if self:GetData().flip and flip then
			FinalAngle.p = -180
			FinalAngle.y = -180 + FinalAngle.y
			FinalPos.z = FinalPos.z + mc.STEP
		end

		ent:SetAngles(FinalAngle)
		ent:SetPos(FinalPos)

		if MCSWEP2.DRAW_BLOCKPLACE_COLOR:GetBool() then
			render.SetColorModulation(mc.GetVisualPlaceColorBlend())
			render.SetBlend(.4 + math.sin(CurTimeL() * 5) * .1)

			ent:DrawModel()

			if IsValid(tr.Entity) and tr.Entity.IsMCBlock then
				render.SetColorModulation(mc.GetVisualRemoveColorBlend())

				tr.Entity.IS_RENDERING = true
				tr.Entity:Draw()
				tr.Entity.IS_RENDERING = false
			end

			render.SetColorModulation(1, 1, 1)
			render.SetBlend(1)
		else
			render.SetBlend(.4 + math.sin(CurTimeL() * 5) * .1)
			ent:DrawModel()
			render.SetBlend(1)
		end
	end

	cam.End3D()
end

function SWEP:Reload()
	if CLIENT then return end
	if not self:GetOwner():KeyDown(IN_RELOAD) then return end
	self.NextReload = self.NextReload or 0
	if self.NextReload > CurTimeL() then return end
	self.NextReload = CurTimeL() + 1
	net.Start('MCSWEP2.OpenMenu')
	net.Send(self:GetOwner())
end

function SWEP:RealPrimaryAttack()
	local tr = self:Trace()
	local ent = tr.Entity
	if not IsValid(ent) then return end
	if not ent.IsMCBlock then return end

	if not ent:CanBeRemoved(self:GetOwner()) then return end

	ent:PlaySound()
	ent:Sparkles()
	ent:Remove()
end

--Need to add more
local TryPositions = {
	Vector(0, 0, -mc.STEP + 4),
}

function SWEP:FindNicePlace(pos)
	local sharp = mc.SharpVector(pos)

	if mc.IsPosFreeFromBlock(sharp) then
		return pos
	else
		for k, v in ipairs(TryPositions) do
			if mc.IsPosFreeFromBlock(sharp + v) then
				return sharp + v
			end
		end
	end

	return pos
end

function SWEP:RealSecondaryAttack()
	local tr, flip, direction = self:Trace()
	if not tr.Hit then return end
	self:PlaceBlock(self:FindNicePlace(tr.HitPos + tr.HitNormal * MCSWEP2.STEP / 2), flip, direction)
end

function SWEP:PrimaryAttack()
	if CLIENT then return end
	local swap = tobool(self:ClientNumber('cl_mc_swap', 0))

	if not swap then
		self:RealPrimaryAttack()
	else
		self:RealSecondaryAttack()
	end
end

function SWEP:SecondaryAttack()
	if CLIENT then return end
	local swap = tobool(self:ClientNumber('cl_mc_swap', 0))

	if not swap then
		self:RealSecondaryAttack()
	else
		self:RealPrimaryAttack()
	end
end

function SWEP:OnRemove()
	if CLIENT then
		if IsValid(self.ClientsideModel) then
			self.ClientsideModel:Remove()
		end
	end
end

weapons.Register(SWEP, 'dbot_mcswep')
