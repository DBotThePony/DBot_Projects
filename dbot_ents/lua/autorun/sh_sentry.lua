
local PlayerHit = {
	'%s now without head',
	'%s got headache',
	'Headshot, mate',
	'Get rekt %s',
	'%s OWNED',
	'sup m8',
	'quickscoped u m8',
	'm8, get a job',
	'Is that hurts, %s?',
	'goodnight m8',
	'%s is ded',
	'%s\' skull got penetrated',
}

local function GetLerp()
	return FrameTime() * 66
end

DSentries = DSentries or {}

function DSentry_GetEntityHitpoint(ENT2)
	if ENT2:IsPlayer() and ENT2:InVehicle() and IsValid(ENT2:GetVehicle()) then
		return DSentry_GetEntityHitpoint(ENT2:GetVehicle())
	end
	
	local EYES2 = ENT2.LookupAttachment and ENT2:LookupAttachment("head") or 0
	
	if EYES2 and EYES2 ~= 0 then
		local vec = ENT2:GetAttachment(EYES2)
		return vec.Pos + Vector(0, 0, -2)
	end
	
	local EYES = ENT2.LookupAttachment and ENT2:LookupAttachment("eyes") or 0
	local eyePos
	
	if EYES and EYES ~= 0 then
		local vec = ENT2:GetAttachment(EYES)
		return vec.Pos + Vector(0, 0, -2)
	end
	local center = ENT2:OBBCenter()
	
	if center then
		return center + ENT2:GetPos()
	end
	
	return ENT2:GetPos() + Vector(0, 0, 3)
end

function GetDSentries()
	local reply = {}
	
	local ents1 = ents.FindByClass('dbot_sentry')
	local ents2 = ents.FindByClass('dbot_sentry_r')
	local ents3 = ents.FindByClass('dbot_sentry_a')
	
	for k, v in ipairs(ents1) do
		table.insert(reply, v)
	end
	
	for k, v in ipairs(ents2) do
		table.insert(reply, v)
	end
	
	for k, v in ipairs(ents3) do
		table.insert(reply, v)
	end
	
	return reply
end

local ENT = {}
ENT.PrintName = 'Bullseye'
ENT.Author = 'DBot'
ENT.Type = 'anim'
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.AdminOnly = true

function ENT:Initialize()
	if CLIENT then return end
	self:SetModel('models/jaanus/wiretool/wiretool_siren.mdl')
	self:PhysicsInitBox(Vector(-10, -10, 0), Vector(10, 10, 10))
	self:SetMoveType(MOVETYPE_VPHYSICS)
	
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:EnableMotion(false)
	end
end

function ENT:OnTakeDamage(dmg)
	dmg:SetDamageForce(Vector())
end

scripted_ents.Register(ENT, 'dbot_bullseye')
