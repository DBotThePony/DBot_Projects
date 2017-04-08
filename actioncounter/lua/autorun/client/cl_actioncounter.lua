local init
init = function()
  if not DNotify then
    print('-------------------------------------------------------')
    print('-- ACTION COUNTER WAS INSTALLED WITHOUT DNOTIFY LIBRARY')
    print('-- THIS WILL NOT WORK')
    print('-------------------------------------------------------')
    return 
  end
  local HUInMeter = 40
  local DISABLE = CreateConVar('cl_ac_disable', '0', {
    FCVAR_ARCHIVE
  }, 'Disable action counter display')
  local NetworkedValues = {
    {
      'jump',
      'Jump streak: %s'
    },
    {
      'speed',
      'Run distance: %sm'
    },
    {
      'duck',
      'Duck distance: %sm'
    },
    {
      'walk',
      'Walk distance: %sm'
    },
    {
      'water',
      'On water distance: %sm'
    },
    {
      'uwater',
      'Underwater distance: %sm'
    },
    {
      'fall',
      'Fall distance: %sm'
    },
    {
      'climb',
      'Climb distance: %sm'
    },
    {
      'height',
      'Maximal potential height: %sm'
    }
  }
  for _index_0 = 1, #NetworkedValues do
    local nData = NetworkedValues[_index_0]
    nData.func = function(self)
      if nData.lastChange > RealTime() - 4 then
        if nData[1] ~= 'jump' then
          self:SetText(nData[2]:format(math.floor(nData.networkValue / HUInMeter * 10) / 10))
        else
          self:SetText(nData[2]:format(nData.networkValue))
        end
        return self:ExtendTimer()
      end
    end
  end
  local NET
  NET = function()
    if DISABLE:GetBool() then
      return 
    end
    for _index_0 = 1, #NetworkedValues do
      local _continue_0 = false
      repeat
        local nData = NetworkedValues[_index_0]
        local readValue = net.ReadUInt(32)
        if readValue == 0 then
          _continue_0 = true
          break
        end
        nData.networkValue = nData.networkValue or readValue
        local changed = nData.networkValue ~= readValue
        nData.networkValue = readValue
        if changed then
          nData.lastChange = RealTime()
        end
        _continue_0 = true
      until true
      if not _continue_0 then
        break
      end
    end
  end
  local Think
  Think = function()
    if DISABLE:GetBool() then
      return 
    end
    local ctime = RealTime() - 4
    for _index_0 = 1, #NetworkedValues do
      local nData = NetworkedValues[_index_0]
      if nData.lastChange and nData.lastChange > ctime then
        if not nData.notif or not nData.notif:IsValid() then
          nData.notif = DNotify.CreateSlide()
          nData.notif:SetThink(nData.func)
          nData.notif:SetNotifyInConsole(false)
          nData.notif:Start()
          nData.notif:Think()
        end
      end
    end
  end
  hook.Add('Think', 'DActionCounter', Think)
  return net.Receive('dactioncounter_network', NET)
end
timer.Simple(0, init)
