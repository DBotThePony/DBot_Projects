include('shared.lua')
ENT.Initialize = function(self)
  self.BaseClass.Initialize(self)
  self.idleSound = CreateSound(self, 'weapons/dispenser_idle.wav')
  self.idleSound:ChangeVolume(0.75)
  self.idleSound:SetSoundLevel(75)
  self.idleSound:Play()
  self.lastArrowAngle = 0
end
ENT.OnRemove = function(self)
  if self.idleSound then
    return self.idleSound:Stop()
  end
end
ENT.Think = function(self)
  return self.BaseClass.Think(self)
end
local SCREEN_BG_RED = Material('vgui/dispenser_meter_bg_red')
local SCREEN_BG_BLUE = Material('vgui/dispenser_meter_bg_blue')
local SCREEN_BG_ARROW = Material('vgui/dispenser_meter_arrow')
local SCREEN_DIST = 7
local SCREEN_POS_1 = Vector(SCREEN_DIST, 1, 42)
local ARROW_POS_1 = Vector(SCREEN_DIST + .1, 1, 38)
local SCREEN_POS_2 = Vector(-SCREEN_DIST, 1, 42)
local ARROW_POS_2 = Vector(-SCREEN_DIST - 0.1, 1, 38)
local SCREEN_COLOR = Color(255, 255, 255)
local WIDTH = 256 / 12
local HEIGHT = 128 / 12
local WIDTH_ARROW = 32 / 12
local HEIGHT_ARROW = 128 / 12
ENT.Draw = function(self)
  self.BaseClass.Draw(self)
  local screenMat
  if self:GetTeamType() then
    screenMat = SCREEN_BG_BLUE
  end
  if not self:GetTeamType() then
    screenMat = SCREEN_BG_RED
  end
  local lpos = self:GetPos()
  local ang = self:GetAngles()
  local fwd = ang:Forward()
  self.lastArrowAngle = Lerp(0.1, self.lastArrowAngle, self:GetAvaliablePercent() * 180)
  render.OverrideDepthEnable(true, true)
  do
    local pos = Vector(SCREEN_POS_1)
    pos:Rotate(ang)
    pos = pos + lpos
    render.SetMaterial(screenMat)
    render.DrawQuadEasy(pos, fwd, WIDTH, HEIGHT, SCREEN_COLOR, 180)
  end
  do
    local pos = Vector(ARROW_POS_1)
    pos:Rotate(ang)
    pos = pos + lpos
    local rad = -math.rad(self.lastArrowAngle)
    local sin, cos = math.sin(rad), math.cos(rad)
    local addVector = Vector(0, -cos * 4.5, -sin * 4.5)
    addVector:Rotate(ang)
    pos = pos + addVector
    render.SetMaterial(SCREEN_BG_ARROW)
    render.DrawQuadEasy(pos, fwd, WIDTH_ARROW, HEIGHT_ARROW, SCREEN_COLOR, -90 - self.lastArrowAngle)
  end
  do
    local pos = Vector(SCREEN_POS_2)
    pos:Rotate(ang)
    pos = pos + lpos
    render.SetMaterial(screenMat)
    render.DrawQuadEasy(pos, -fwd, WIDTH, HEIGHT, SCREEN_COLOR, 180)
  end
  do
    local pos = Vector(ARROW_POS_2)
    pos:Rotate(ang)
    pos = pos + lpos
    local rad = -math.rad(self.lastArrowAngle + 180)
    local sin, cos = math.sin(rad), math.cos(rad)
    local addVector = Vector(0, -cos * 4.5, sin * 4.5)
    addVector:Rotate(ang)
    pos = pos + addVector
    render.SetMaterial(SCREEN_BG_ARROW)
    render.DrawQuadEasy(pos, -fwd, WIDTH_ARROW, HEIGHT_ARROW, SCREEN_COLOR, -90 - self.lastArrowAngle)
  end
  return render.OverrideDepthEnable(false, true)
end
