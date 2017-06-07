DTF2 = DTF2 or { }
local BACKGROUND_COLOR = Color(0, 0, 0, 150)
local FONT_COLOR = Color(255, 255, 255)
local FONT_COLOR_GREEN = Color(88, 183, 56)
local FONT_COLOR_RED = Color(217, 101, 83)
local COLOR_HP_BAR_BACKGROUND = Color(176, 176, 176)
local COLOR_HP_BAR = Color(167, 197, 92)
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
    color = event and FONT_COLOR_GREEN or FONT_COLOR_RED
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
DTF2.DrawMetalCounter = function()
  local w, h = ScrW(), ScrH()
  local x, y = w * .8, h * .95
  local text = "Avaliable Metal: " .. tostring(LocalPlayer():GetTF2Metal())
  surface.SetFont(FONT)
  surface.SetDrawColor(BACKGROUND_COLOR)
  surface.SetTextColor(FONT_COLOR)
  local W, H = surface.GetTextSize(text)
  surface.DrawRect(x - 4, y - 4, W + 8, H + 8)
  surface.SetTextPos(x, y)
  surface.DrawText(text)
  x = x + 110
  for _index_0 = 1, #METAL_HISTORY do
    local data = METAL_HISTORY[_index_0]
    W, H = surface.GetTextSize(data.text)
    surface.SetDrawColor(Color(0, 0, 0, 150 * data.fade))
    surface.DrawRect(x - 4, y - 4 - data.slide, W + 8, H + 8)
    surface.SetTextPos(x, y - data.slide)
    surface.SetTextColor(data.r, data.g, data.b, data.a)
    surface.DrawText(data.text)
  end
end
local BAR_BACKGROUND = Color(168, 168, 168)
local BAR_COLOR = Color(235, 235, 235)
DTF2.DrawCenteredBar = function(mult, text)
  if mult == nil then
    mult = 0.5
  end
  local w, h = ScrW(), ScrH()
  local x, y = w * .5, h * .55
  surface.SetDrawColor(BACKGROUND_COLOR)
  surface.DrawRect(x - 154, y - 4, 308, 38)
  surface.SetDrawColor(BAR_BACKGROUND)
  surface.DrawRect(x - 150, y, 300, 30)
  surface.SetDrawColor(BAR_COLOR)
  surface.DrawRect(x - 150, y, 300 * mult, 30)
  if text then
    surface.SetFont(FONT)
    surface.SetDrawColor(BACKGROUND_COLOR)
    surface.SetTextColor(FONT_COLOR)
    local W, H = surface.GetTextSize(text)
    surface.DrawRect(x - 4 - 154, y - 4 - H, W + 8, H + 8)
    surface.SetTextPos(x - 150, y - H)
    return surface.DrawText(text)
  end
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
  surface.SetFont(FONT)
  surface.SetDrawColor(BACKGROUND_COLOR)
  surface.SetTextColor(FONT_COLOR)
  local W, H = surface.GetTextSize(text)
  W = math.max(W, 200)
  surface.DrawRect(x - 4 - W / 2, y - 4, W + 8, H + 8)
  surface.SetTextPos(x - W / 2, y)
  draw.DrawText(text, FONT, x - W / 2, y, FONT_COLOR)
  surface.SetDrawColor(COLOR_HP_BAR_BACKGROUND)
  surface.DrawRect(x - W / 2, y + H - 12, W, 12)
  surface.SetDrawColor(COLOR_HP_BAR)
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
