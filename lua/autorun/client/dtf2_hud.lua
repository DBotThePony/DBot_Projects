DTF2 = DTF2 or { }
local BACKGROUND_COLOR = HUDCommons.CreateColor('dtf2_background', 'DTF2 HUD Background', 0, 0, 0, 150)
local FONT_COLOR = HUDCommons.CreateColor('dtf2_font', 'DTF2 Font', 255, 255, 255)
local FONT_COLOR_GREEN = HUDCommons.CreateColor('dtf2_font_positive', 'DTF2 HUD positive text', 88, 183, 56)
local FONT_COLOR_RED = HUDCommons.CreateColor('dtf2_font_negative', 'DTF2 HUD negative text', 217, 101, 83)
local COLOR_HP_BAR_BACKGROUND = HUDCommons.CreateColor('dtf2_hpbar_background', 'DTF2 HUD HP Bar Background', 176, 176, 176)
local COLOR_HP_BAR = HUDCommons.CreateColor('dtf2_hpbar', 'DTF2 HUD HP Bar', 167, 197, 92)
local HUD_BAR_BACKGROUND = HUDCommons.CreateColor('dtf2_bar_bg', 'DTF2 HUD generic bar background', 168, 168, 168)
local HUD_BAR_COLOR = HUDCommons.CreateColor('dtf2_bar', 'DTF2 HUD generic bar', 235, 235, 235)
local FONT = 'DTF2.HUDFont'
surface.CreateFont(FONT, {
  ['font'] = 'Roboto',
  ['size'] = 18,
  ['weight'] = 400
})
local METAL_HISTORY = { }
local UPDATE_HISTORY = false
hook.Add('Think', 'DTF2.UpdateMetalHistory', function()
  local rTime = RealTime()
  if UPDATE_HISTORY then
    do
      local _accum_0 = { }
      local _len_0 = 1
      for _index_0 = 1, #METAL_HISTORY do
        local data = METAL_HISTORY[_index_0]
        if data.endtime > rTime then
          _accum_0[_len_0] = data
          _len_0 = _len_0 + 1
        end
      end
      METAL_HISTORY = _accum_0
    end
    UPDATE_HISTORY = false
  end
  for _index_0 = 1, #METAL_HISTORY do
    local data = METAL_HISTORY[_index_0]
    if data.endtime < rTime then
      UPDATE_HISTORY = true
    end
    data.fade = (data.endtime - rTime) / 5
    data.a = data.fade * 255
    data.slide = data.slide + (FrameTime() * 25)
  end
end)
hook.Add('DTF2.MetalEffect', 'DTF2.MetalHistory', function(event, amount)
  if event == nil then
    event = true
  end
  if amount == nil then
    amount = 0
  end
  if amount == 0 then
    return 
  end
  local data = {
    start = RealTime(),
    endtime = RealTime() + 5,
    slide = 0,
    fade = 1,
    text = event and "+" .. tostring(amount) or "-" .. tostring(amount),
    color = event and FONT_COLOR_GREEN() or FONT_COLOR_RED()
  }
  table.insert(METAL_HISTORY, data)
  local r, g, b
  do
    local _obj_0 = data.color
    r, g, b = _obj_0.r, _obj_0.g, _obj_0.b
  end
  data.r = r
  data.g = g
  data.b = b
  data.a = 255
end)
local METAL_COUNTER_POS = HUDCommons.DefinePosition('dtf2_metal_counter', .8, .95)
DTF2.DrawMetalCounter = function()
  local x, y = METAL_COUNTER_POS()
  HUDCommons.WordBox("Avaliable Metal: " .. tostring(LocalPlayer():GetTF2Metal()), FONT, x, y, FONT_COLOR, BACKGROUND_COLOR())
  x = x + 110
  for _index_0 = 1, #METAL_HISTORY do
    local data = METAL_HISTORY[_index_0]
    HUDCommons.WordBox(data.text, nil, x, y - data.slide, Color(data.r, data.g, data.b, data.a), Color(0, 0, 0, 150 * data.fade))
  end
end
local CENTERED_BAR_POS = HUDCommons.DefinePosition('dtf2_centered', .5, .65)
DTF2.DrawCenteredBar = function(mult, text)
  if mult == nil then
    mult = 0.5
  end
  local x, y = CENTERED_BAR_POS()
  surface.SetTextColor(FONT_COLOR())
  surface.SetFont(FONT)
  return HUDCommons.BarWithTextCentered(x, y, 300, 25, mult, BACKGROUND_COLOR(), HUD_BAR_BACKGROUND(), HUD_BAR_COLOR(), text)
end
DTF2.DrawBuildingInfo = function(self)
  local w, h = ScrW(), ScrH()
  local x, y = w * .5, h * .6
  local text = self.PrintName
  if IsValid(self:GetPlayer()) and self:GetPlayer():IsPlayer() then
    text = text .. " built by " .. tostring(self:GetPlayer():Nick())
  end
  local hp, mhp = self:Health(), self:GetMaxHealth()
  text = text .. "\nHealth: " .. tostring(hp) .. "/" .. tostring(mhp)
  if self:GetLevel() < 3 then
    text = text .. "\nUpgrade level: " .. tostring(self:GetUpgradeAmount()) .. "/" .. tostring(self.MAX_UPGRADE)
  end
  text = text .. '\n'
  text = text .. self:GetHUDText()
  local W, H = HUDCommons.AdvancedWordBox(text, FONT, x, y, FONT_COLOR(), BACKGROUND_COLOR(), true)
  surface.SetDrawColor(COLOR_HP_BAR_BACKGROUND())
  surface.DrawRect(x - W / 2, y + H - 12, W, 12)
  surface.SetDrawColor(COLOR_HP_BAR())
  return surface.DrawRect(x - W / 2, y + H - 12, W * math.Clamp(hp / mhp, 0, 1), 12)
end
return hook.Add('HUDPaint', 'DTF2.BuildablesHUD', function()
  local self = LocalPlayer():GetEyeTrace().Entity
  if not IsValid(self) then
    return 
  end
  if not self.IsTF2Building then
    return 
  end
  return self:DrawHUD()
end)
