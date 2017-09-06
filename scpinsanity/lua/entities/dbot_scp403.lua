local RESET_TIMER = CreateConVar('sv_scpi_403_timer', '60', {
  FCVAR_ARCHIVE,
  FCVAR_REPLICATED,
  FCVAR_NOTIFY
}, 'SCP 403 reset timer in seconds')
AddCSLuaFile()
ENT.Type = 'anim'
ENT.PrintName = 'SCP-403'
ENT.Author = 'DBot'
ENT.Category = 'SCP Insanity'
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.AdminOnly = true
ENT.Initialize = function(self)
  self:SetModel('models/zippocollectionnavy.mdl')
  if CLIENT then
    return 
  end
  self:SetSolid(SOLID_VPHYSICS)
  self:SetMoveType(MOVETYPE_VPHYSICS)
  self:PhysicsInit(SOLID_VPHYSICS)
  self.phys = self:GetPhysicsObject()
  self:SetUseType(SIMPLE_USE)
  self:UseTriggerBounds(true, 24)
  if IsValid(self.phys) then
    self.phys:SetMass(5)
    self.phys:Wake()
  end
  self.NextReset = CurTime()
  self.ExplosionCounter = -1
end
if SERVER then
  ENT.Think = function(self)
    self.NextReset = CurTime() + RESET_TIMER:GetFloat()
    self:NextThink(self.NextReset)
    self.ExplosionCounter = -1
    return true
  end
  ENT.DoWaterEffect = function(self)
    local trData = {
      mask = MASK_WATER + CONTENTS_TRANSLUCENT,
      start = self:GetPos(),
      endpos = self:GetPos() - Vector(0, 0, 2000),
      filter = self
    }
    return ParticleEffect('water_medium', util.TraceLine(trData).HitPos, Angle(0, 0, 0))
  end
  ENT.DoGroundEffect = function(self, part)
    if part == nil then
      part = '100lb_ground'
    end
    local trData = {
      start = self:GetPos(),
      endpos = self:GetPos() - Vector(0, 0, 2000),
      filter = self
    }
    return ParticleEffect(part, util.TraceLine(trData).HitPos, Angle(0, 0, 0))
  end
  ENT.Use = function(self, user)
    self.ExplosionCounter = self.ExplosionCounter + 1
    if self.ExplosionCounter > 3 then
      self.ExplosionCounter = 3
    end
    self:EmitSound('buttons/button9.wav', SNDLVL_50dB)
    local pos = self:GetPos()
    local _exp_0 = self.ExplosionCounter
    if 1 == _exp_0 then
      if self:WaterLevel() > 0 then
        self:DoWaterEffect()
      else
        self:DoGroundEffect('100lb_ground')
      end
      local dmginfo = DamageInfo()
      dmginfo:SetAttacker(user)
      dmginfo:SetInflictor(self)
      dmginfo:SetDamage(50)
      dmginfo:SetDamageType(DMG_BLAST)
      local _list_0 = ents.FindInSphere(pos, 400)
      for _index_0 = 1, #_list_0 do
        local ent = _list_0[_index_0]
        if ent ~= self and ent ~= user and ent:GetPos():Distance(pos) > 200 then
          ent:TakeDamageInfo(dmginfo)
        end
      end
      for i = 1, 3 do
        self:EmitSound("gbombs_5/explosions/light_bomb/small_explosion_" .. tostring(math.random(1, 7)) .. ".mp3", SNDLVL_140dB)
      end
    elseif 2 == _exp_0 then
      if self:WaterLevel() > 0 then
        self:DoWaterEffect()
      else
        self:DoGroundEffect('100lb_ground')
      end
      local dmginfo = DamageInfo()
      dmginfo:SetAttacker(user)
      dmginfo:SetInflictor(self)
      dmginfo:SetDamage(250)
      dmginfo:SetDamageType(DMG_BLAST)
      local _list_0 = ents.FindInSphere(pos, 1000)
      for _index_0 = 1, #_list_0 do
        local ent = _list_0[_index_0]
        if ent ~= self and ent ~= user and ent:GetPos():Distance(pos) > 200 then
          ent:TakeDamageInfo(dmginfo)
        end
      end
      for i = 1, 5 do
        self:EmitSound("gbombs_5/explosions/heavy_bomb/explosion_big_" .. tostring(math.random(1, 7)) .. ".mp3", SNDLVL_180dB)
      end
    elseif 3 == _exp_0 then
      if self:WaterLevel() > 0 then
        self:DoWaterEffect()
      else
        self:DoGroundEffect('100lb_ground')
      end
      local dmginfo = DamageInfo()
      dmginfo:SetAttacker(user)
      dmginfo:SetInflictor(self)
      dmginfo:SetDamage(800)
      dmginfo:SetDamageType(DMG_BLAST)
      local _list_0 = ents.FindInSphere(pos, 1900)
      for _index_0 = 1, #_list_0 do
        local ent = _list_0[_index_0]
        if ent ~= self and ent ~= user and ent:GetPos():Distance(pos) > 200 then
          ent:TakeDamageInfo(dmginfo)
        end
      end
      for i = 1, 7 do
        self:EmitSound("gbombs_5/explosions/nuclear/fat_explosion.mp3", SNDLVL_180dB)
      end
    end
  end
end
