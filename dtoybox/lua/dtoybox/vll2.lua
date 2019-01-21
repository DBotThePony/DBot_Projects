
-- Copyright (C) 2018 DBot

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

-- To Load VLL2 you can use any of these commands:
-- lua_run http.Fetch("https://dbotthepony.ru/vll/vll2.lua",function(b)RunString(b,"VLL2")end,function(err)print("VLL2",err)end)
-- rcon lua_run "http.Fetch([[https:]]..string.char(47)..[[/dbotthepony.ru/vll/vll2.lua]],function(b)RunString(b,[[VLL2]])end,function(err)print([[VLL2]],err)end)"
-- http.Fetch('https://dbotthepony.ru/vll/vll2.lua',function(b)RunString(b,'VLL2')end,function(err)print('VLL2',err)end)
-- ulx luarun "http.Fetch('https://dbotthepony.ru/vll/vll2.lua',function(b)RunString(b,'VLL2')end,function(err)print('VLL2',err)end)"

local __cloadStatus, _cloadError = pcall(function()

if VLL2 then
  pcall(function()
    return VLL2.Message('VLL2 was reloaded')
  end)
end
VLL2 = { }
VLL2.IS_WEB_LOADED = debug.getinfo(1).short_src == 'VLL2'
local SERVER, CLIENT, string, game, GetHostName, table, util, MsgC, Color
do
  local _obj_0 = _G
  SERVER, CLIENT, string, game, GetHostName, table, util, MsgC, Color = _obj_0.SERVER, _obj_0.CLIENT, _obj_0.string, _obj_0.game, _obj_0.GetHostName, _obj_0.table, _obj_0.util, _obj_0.MsgC, _obj_0.Color
end
local PREFIX_COLOR = Color(0, 200, 0)
local DEFAULT_TEXT_COLOR = Color(200, 200, 200)
local BOOLEAN_COLOR = Color(33, 83, 226)
local NUMBER_COLOR = Color(245, 199, 64)
local STEAMID_COLOR = Color(255, 255, 255)
local ENTITY_COLOR = Color(180, 232, 180)
local FUNCTION_COLOR = Color(62, 106, 255)
local TABLE_COLOR = Color(107, 200, 224)
local URL_COLOR = Color(174, 124, 192)
local WriteArray
WriteArray = function(arr)
  net.WriteUInt(#arr, 16)
  local _list_0 = arr
  for _index_0 = 1, #_list_0 do
    local val = _list_0[_index_0]
    net.WriteType(val)
  end
end
local ReadArray
ReadArray = function()
  local _accum_0 = { }
  local _len_0 = 1
  for i = 1, net.ReadUInt(16) do
    _accum_0[_len_0] = net.ReadType()
    _len_0 = _len_0 + 1
  end
  return _accum_0
end
if SERVER then
  util.AddNetworkString('vll2.message')
else
  net.Receive('vll2.message', function()
    return VLL2.Message(unpack(ReadArray()))
  end)
end
VLL2.Referer = function()
  return (SERVER and '(SERVER) ' or '(CLIENT) ') .. string.Explode(':', game.GetIPAddress())[1] .. '/' .. GetHostName()
end
VLL2.FormatMessageInternal = function(tabIn)
  local prevColor = DEFAULT_TEXT_COLOR
  local output = {
    prevColor
  }
  for _, val in ipairs(tabIn) do
    local valType = type(val)
    if valType == 'number' then
      table.insert(output, NUMBER_COLOR)
      table.insert(output, tostring(val))
      table.insert(output, prevColor)
    elseif valType == 'string' then
      if val:find('^https?://') then
        table.insert(output, URL_COLOR)
        table.insert(output, val)
        table.insert(output, prevColor)
      else
        table.insert(output, val)
      end
    elseif valType == 'Player' then
      if team then
        table.insert(output, team.GetColor(val:Team()) or ENTITY_COLOR)
      else
        table.insert(output, ENTITY_COLOR)
      end
      table.insert(output, val:Nick())
      if val.SteamName and val:SteamName() ~= val:Nick() then
        table.insert(output, ' (' .. val:SteamName() .. ')')
      end
      table.insert(output, STEAMID_COLOR)
      table.insert(output, '<')
      table.insert(output, val:SteamID())
      table.insert(output, '>')
      table.insert(output, prevColor)
    elseif valType == 'Entity' or valType == 'NPC' or valType == 'Vehicle' then
      table.insert(output, ENTITY_COLOR)
      table.insert(output, tostring(val))
      table.insert(output, prevColor)
    elseif valType == 'table' then
      if val.r and val.g and val.b then
        table.insert(output, val)
        prevColor = val
      else
        table.insert(output, TABLE_COLOR)
        table.insert(output, tostring(val))
        table.insert(output, prevColor)
      end
    elseif valType == 'function' then
      table.insert(output, FUNCTION_COLOR)
      table.insert(output, string.format('function - %p', val))
      table.insert(output, prevColor)
    elseif valType == 'boolean' then
      table.insert(output, BOOLEAN_COLOR)
      table.insert(output, tostring(val))
      table.insert(output, prevColor)
    else
      table.insert(output, tostring(val))
    end
  end
  return output
end
local genPrefix
genPrefix = function()
  if game.SinglePlayer() then
    return SERVER and '[SV] ' or '[CL] '
  elseif game.IsDedicated() then
    return ''
  end
  if CLIENT then
    return ''
  end
  if SERVER and game.GetIPAddress() == '0.0.0.0' then
    return '[SV] '
  end
  return ''
end
VLL2.Message = function(...)
  local formatted = VLL2.FormatMessageInternal({
    ...
  })
  MsgC(PREFIX_COLOR, genPrefix() .. '[VLL2] ', unpack(formatted))
  MsgC('\n')
  return formatted
end
VLL2.MessageVM = function(...)
  local formatted = VLL2.FormatMessageInternal({
    ...
  })
  MsgC(PREFIX_COLOR, genPrefix() .. '[VLL2:VM] ', unpack(formatted))
  MsgC('\n')
  return formatted
end
VLL2.MessageFS = function(...)
  local formatted = VLL2.FormatMessageInternal({
    ...
  })
  MsgC(PREFIX_COLOR, genPrefix() .. '[VLL2:FS] ', unpack(formatted))
  MsgC('\n')
  return formatted
end
VLL2.MessageDL = function(...)
  local formatted = VLL2.FormatMessageInternal({
    ...
  })
  MsgC(PREFIX_COLOR, genPrefix() .. '[VLL2:DL] ', unpack(formatted))
  MsgC('\n')
  return formatted
end
VLL2.MessageBundle = function(...)
  local formatted = VLL2.FormatMessageInternal({
    ...
  })
  MsgC(PREFIX_COLOR, genPrefix() .. '[VLL2:BNDL] ', unpack(formatted))
  MsgC('\n')
  return formatted
end
VLL2.MessagePlayer = function(ply, ...)
  if CLIENT or ply == NULL or ply == nil then
    VLL2.Message(...)
    return 
  end
  net.Start('vll2.message')
  WriteArray({
    ...
  })
  return net.Send(ply)
end
if SERVER then
  if VLL2.IS_WEB_LOADED then
    hook.Add('PlayerInitialSpawn', 'VLL2.LoadOnClient', function(ply)
      return timer.Simple(10, function()
        if IsValid(ply) then
          return ply:SendLua([[if VLL2 then return end http.Fetch('https://dbotthepony.ru/vll/vll2.lua',function(b)RunString(b,'VLL2')end,function(err)print('VLL2',err)end)]])
        end
      end)
    end)
    if not VLL2_GOING_TO_RELOAD then
      local _list_0 = player.GetAll()
      for _index_0 = 1, #_list_0 do
        local ply = _list_0[_index_0]
        ply:SendLua([[if VLL2 then return end http.Fetch('https://dbotthepony.ru/vll/vll2.lua',function(b)RunString(b,'VLL2')end,function(err)print('VLL2',err)end)]])
      end
    end
    if VLL2_FULL_RELOAD then
      local _list_0 = player.GetAll()
      for _index_0 = 1, #_list_0 do
        local ply = _list_0[_index_0]
        ply:SendLua([[http.Fetch('https://dbotthepony.ru/vll/vll2.lua',function(b)RunString(b,'VLL2')end,function(err)print('VLL2',err)end)]])
      end
      _G.VLL2_FULL_RELOAD = false
    end
    _G.VLL2_GOING_TO_RELOAD = false
  else
    AddCSLuaFile()
    return hook.Remove('PlayerInitialSpawn', 'VLL2.LoadOnClient')
  end
end

end)

if not __cloadStatus then
	print('UNABLE TO LOAD VLL2 CORE')
	print('LOAD CAN NOT CONTINUE')
	print('REASON:')
	print(_cloadError)
	return
end

VLL2.Message('Starting up...')
local ___status, ___err = pcall(function()
local VLL2, baseclass, table, string, assert, type
do
  local _obj_0 = _G
  VLL2, baseclass, table, string, assert, type = _obj_0.VLL2, _obj_0.baseclass, _obj_0.table, _obj_0.string, _obj_0.assert, _obj_0.type
end
VLL2.RecursiveMergeBase = function(mergeMeta)
  if not mergeMeta then
    return 
  end
  local metaGet = baseclass.Get(mergeMeta)
  if not metaGet.Base then
    return 
  end
  if metaGet.Base == mergeMeta then
    return 
  end
  VLL2.RecursiveMergeBase(metaGet.Base)
  local metaBase = baseclass.Get(metaGet.Base)
  for key, value in pairs(metaBase) do
    if metaGet[key] == nil then
      metaGet[key] = value
    end
  end
end
VLL2.API = {
  LoadBundle = function(bundleName, silent, replicate)
    if silent == nil then
      silent = false
    end
    if replicate == nil then
      replicate = true
    end
    assert(type(bundleName) == 'string', 'Bundle name must be a string')
    local fbundle = VLL2.URLBundle(bundleName:lower())
    fbundle:Load()
    if not silent then
      fbundle:Replicate()
    end
    fbundle:SetReplicate(replicate)
    return fbundle
  end,
  LoadWorkshopContent = function(wsid, silent, replicate)
    if silent == nil then
      silent = false
    end
    if replicate == nil then
      replicate = true
    end
    assert(type(wsid) == 'string', 'Bundle wsid must be a string')
    wsid = tostring(math.floor(assert(tonumber(wsid), 'Bundle wsid must represent a valid number within string!')))
    local fbundle = VLL2.WSBundle(wsid)
    fbundle:Load()
    fbundle:DoNotLoadLua()
    if not silent then
      fbundle:Replicate()
    end
    fbundle:SetReplicate(replicate)
    return fbundle
  end,
  LoadURLContent = function(name, url, silent, replicate)
    if silent == nil then
      silent = false
    end
    if replicate == nil then
      replicate = true
    end
    assert(type(name) == 'string', 'Bundle name must be a string')
    assert(type(url) == 'string', 'Bundle url must be a string')
    local fbundle = VLL2.URLGMABundle(name, url)
    fbundle:Load()
    fbundle:DoNotLoadLua()
    if not silent then
      fbundle:Replicate()
    end
    fbundle:SetReplicate(replicate)
    return fbundle
  end,
  LoadURLGMA = function(name, url, silent, replicate)
    if silent == nil then
      silent = false
    end
    if replicate == nil then
      replicate = true
    end
    assert(type(name) == 'string', 'Bundle name must be a string')
    assert(type(url) == 'string', 'Bundle url must be a string')
    local fbundle = VLL2.URLGMABundle(name, url)
    fbundle:Load()
    if not silent then
      fbundle:Replicate()
    end
    fbundle:SetReplicate(replicate)
    return fbundle
  end,
  LoadURLContentZ = function(name, url, silent, replicate)
    if silent == nil then
      silent = false
    end
    if replicate == nil then
      replicate = true
    end
    assert(type(name) == 'string', 'Bundle name must be a string')
    assert(type(url) == 'string', 'Bundle url must be a string')
    local fbundle = VLL2.URLGMABundleZ(name, url)
    fbundle:Load()
    fbundle:DoNotLoadLua()
    if not silent then
      fbundle:Replicate()
    end
    fbundle:SetReplicate(replicate)
    return fbundle
  end,
  LoadURLGMAZ = function(name, url, silent, replicate)
    if silent == nil then
      silent = false
    end
    if replicate == nil then
      replicate = true
    end
    assert(type(name) == 'string', 'Bundle name must be a string')
    assert(type(url) == 'string', 'Bundle url must be a string')
    local fbundle = VLL2.URLGMABundleZ(name, url)
    fbundle:Load()
    if not silent then
      fbundle:Replicate()
    end
    fbundle:SetReplicate(replicate)
    return fbundle
  end,
  LoadWorkshopCollection = function(wsid, silent, replicate)
    if silent == nil then
      silent = false
    end
    if replicate == nil then
      replicate = true
    end
    assert(type(wsid) == 'string', 'Bundle wsid must be a string')
    wsid = tostring(math.floor(assert(tonumber(wsid), 'Bundle wsid must represent a valid number within string!')))
    local fbundle = VLL2.WSCollection(wsid)
    fbundle:Load()
    if not silent then
      fbundle:Replicate()
    end
    fbundle:SetReplicate(replicate)
    return fbundle
  end,
  LoadWorkshopCollectionContent = function(wsid, silent, replicate)
    if silent == nil then
      silent = false
    end
    if replicate == nil then
      replicate = true
    end
    assert(type(wsid) == 'string', 'Bundle wsid must be a string')
    wsid = tostring(math.floor(assert(tonumber(wsid), 'Bundle wsid must represent a valid number within string!')))
    local fbundle = VLL2.WSCollection(wsid)
    fbundle:Load()
    fbundle:DoNotLoadLua()
    if not silent then
      fbundle:Replicate()
    end
    fbundle:SetReplicate(replicate)
    return fbundle
  end,
  LoadWorkshop = function(wsid, silent, replicate)
    if silent == nil then
      silent = false
    end
    if replicate == nil then
      replicate = true
    end
    assert(type(wsid) == 'string', 'Bundle wsid must be a string')
    wsid = tostring(math.floor(assert(tonumber(wsid), 'Bundle wsid must represent a valid number within string!')))
    local fbundle = VLL2.WSBundle(wsid)
    fbundle:Load()
    if not silent then
      fbundle:Replicate()
    end
    fbundle:SetReplicate(replicate)
    return fbundle
  end
}
do
  local _class_0
  local _base_0 = {
    IsIdle = function(self)
      return self.status == self.__class.STATUS_NONE
    end,
    IsGettingInfo = function(self)
      return self.status == self.__class.STATUS_GETTING_INFO
    end,
    IsWaiting = function(self)
      return self.status == self.__class.STATUS_WAITING
    end,
    IsErrored = function(self)
      return self.status == self.__class.STATUS_ERROR
    end,
    IsDownloading = function(self)
      return self.status == self.__class.STATUS_DOWNLOADING
    end,
    IsFinished = function(self)
      return self.status == self.__class.STATUS_FINISHED
    end,
    Msg = function(self, ...)
      return VLL2.MessageDL(...)
    end,
    AddFinishHook = function(self, fcall)
      table.insert(self.success, fcall)
      return self
    end,
    AddErrorHook = function(self, fcall)
      table.insert(self.failure, fcall)
      return self
    end,
    CallFinish = function(self, ...)
      local _list_0 = self.success
      for _index_0 = 1, #_list_0 do
        local fcall = _list_0[_index_0]
        fcall(self, ...)
      end
    end,
    CallError = function(self, ...)
      local _list_0 = self.failure
      for _index_0 = 1, #_list_0 do
        local fcall = _list_0[_index_0]
        fcall(self, ...)
      end
    end,
    LoadNextPart = function(self)
      local rem = table.remove(self.nextParts, 1)
      if rem then
        return self:DownloadPart(rem)
      end
      if self.inProgressParts ~= 0 then
        self:Msg('Downloaded ' .. string.NiceSize(self.downloaded) .. ' / ' .. string.NiceSize(self.length) .. ' of ' .. self.url)
        return 
      end
      self.status = self.__class.STATUS_FINISHED
      self.fstream:Flush()
      self.fstream:Close()
      self:Msg('File ' .. self.url .. ' got downloaded and saved!')
      self:CallFinish()
      return self.__class:Recalc()
    end,
    DownloadPart = function(self, partid)
      assert(partid <= self.parts, 'Invalid partid')
      for i, part in ipairs(self.nextParts) do
        if part == partid then
          table.remove(self.nextParts, i)
        end
      end
      self.inProgressParts = self.inProgressParts + 1
      local bytesStart, bytesEnd = partid * self.partlen, math.min(self.length - 1, (partid + 1) * self.partlen - 1)
      self.currentMemSize = self.currentMemSize + self.partlen
      local req = {
        method = 'GET',
        url = self.url,
        headers = {
          ['User-Agent'] = 'VLL2',
          ['Range'] = 'bytes=' .. bytesStart .. '-' .. bytesEnd,
          Referer = VLL2.Referer()
        }
      }
      req.failed = function(reason)
        if reason == nil then
          reason = 'failure'
        end
        if self.status == self.__class.STATUS_ERROR then
          return 
        end
        self:Msg('Failed to GET the part of file! ' .. self.url .. ' part ' .. partid .. ' out from ' .. self.parts)
        self:Msg('Reason: ' .. reason)
        self.status = self.__class.STATUS_ERROR
        self:CallError(reason)
        return self.__class:Recalc()
      end
      req.success = function(code, body, headers)
        if code == nil then
          code = 400
        end
        if body == nil then
          body = ''
        end
        if self.status == self.__class.STATUS_ERROR then
          return 
        end
        if code ~= 206 and code ~= 200 then
          self:Msg('Failed to GET the part of file! ' .. self.url .. ' part ' .. partid .. ' out from ' .. self.parts)
          self:Msg('Server replied: ' .. code)
          self.status = self.__class.STATUS_ERROR
          self:CallError('Server replied: ' .. code)
          self.__class:Recalc()
          return 
        end
        for hname, hvalue in pairs(headers) do
          if hname:lower() == 'content-length' then
            if tonumber(hvalue) ~= bytesEnd - bytesStart + 1 then
              self:Msg('Failed to GET the part of file! ' .. self.url .. ' part ' .. partid .. ' out from ' .. self.parts)
              self:Msg('EXPECTED (REQUESTED) LENGTH: ' .. bytesEnd - bytesStart)
              self:Msg('ACTUAL LENGTH REPORTED BY THE SERVER: ' .. hvalue)
              self.status = self.__class.STATUS_ERROR
              self:CallError('Length mismatch')
              self.__class:Recalc()
              return 
            end
          end
        end
        self.downloaded = self.downloaded + (bytesEnd - bytesStart + 1)
        self.fstream:Seek(bytesStart)
        self.fstream:Write(body)
        self.fstream:Flush()
        self.inProgressParts = self.inProgressParts - 1
        return self:LoadNextPart()
      end
      return HTTP(req)
    end,
    Download = function(self)
      file.Delete(self.outputPath)
      self.fstream = file.Open(self.outputPath, 'wb', 'DATA')
      self.status = self.__class.STATUS_DOWNLOADING
      self:Msg('Allocating disk space for ' .. self.url .. '...')
      self.fstream:Seek(self.length - 1)
      self.fstream:WriteByte(0)
      self.fstream:Seek(0)
      do
        local _accum_0 = { }
        local _len_0 = 1
        for i = 0, self.parts - 1 do
          _accum_0[_len_0] = i
          _len_0 = _len_0 + 1
        end
        self.nextParts = _accum_0
      end
      for i = 0, self.parts - 1 do
        self:DownloadPart(i)
        if self.currentMemSize >= self.__class.MAX_MEM_SIZE then
          break
        end
      end
    end,
    CalcParts = function(self)
      local partlen = math.ceil(self.length / 16)
      if partlen < self.__class.MIN_PART_SIZE then
        partlen = self.__class.MIN_PART_SIZE
      end
      if partlen > self.__class.MAX_PART_SIZE then
        partlen = self.__class.MAX_PART_SIZE
      end
      self.parts = math.ceil(self.length / partlen)
      self.partlen = partlen
    end,
    Load = function(self)
      return self:GetInfo()
    end,
    GetInfo = function(self)
      self.status = self.__class.STATUS_GETTING_INFO
      local req = {
        method = 'HEAD',
        url = self.url,
        headers = {
          ['User-Agent'] = 'VLL2',
          Referer = VLL2.Referer()
        }
      }
      req.failed = function(reason)
        if reason == nil then
          reason = 'failure'
        end
        self:Msg('Failed to HEAD the url! ' .. self.url)
        self:Msg('Reason: ' .. reason)
        self.status = self.__class.STATUS_ERROR
        self:CallError(reason)
        return self.__class:Recalc()
      end
      req.success = function(code, body, headers)
        if code == nil then
          code = 400
        end
        if body == nil then
          body = ''
        end
        if code ~= 200 then
          self:Msg('Failed to HEAD the url! ' .. self.url)
          self:Msg('Server replied: ' .. code)
          self.status = self.__class.STATUS_ERROR
          self:CallError('Server replied: ' .. code)
          self.__class:Recalc()
          return 
        end
        self.headers = headers
        for hname, hvalue in pairs(headers) do
          if hname:lower() == 'content-length' then
            self.length = tonumber(hvalue)
            self:CalcParts()
            break
          end
        end
        if self.length == -1 then
          self:Msg('Server did not provided content-length header on HEAD request')
          self:Msg(self.url)
          self:Msg('Load can not continue')
          self.status = self.__class.STATUS_ERROR
          self:CallError('Server lacks content-length')
          self.__class:Recalc()
          return 
        end
        self.status = self.__class.STATUS_WAITING
        return self.__class:Recalc()
      end
      return HTTP(req)
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, urlFrom, fileOutput)
      self.url = urlFrom
      self.outputPath = fileOutput
      self.params = { }
      self.currentMemSize = 0
      self.downloaded = 0
      self.length = -1
      self.inProgressParts = 0
      self.status = self.__class.STATUS_NONE
      self.nextParts = { }
      self.success = { }
      self.failure = { }
      return table.insert(self.__class.PENDING, self)
    end,
    __base = _base_0,
    __name = "LargeFileLoader"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  local self = _class_0
  self.PENDING = { }
  self.STATUS_NONE = 0
  self.STATUS_GETTING_INFO = 1
  self.STATUS_WAITING = 2
  self.STATUS_ERROR = 3
  self.STATUS_DOWNLOADING = 4
  self.STATUS_FINISHED = 5
  self.MIN_PART_SIZE = 1024 * 1024
  self.MAX_PART_SIZE = 1024 * 1024 * 4
  self.MAX_MEM_SIZE = 1024 * 1024 * 64
  self.Recalc = function(self)
    local _list_0 = self.PENDING
    for _index_0 = 1, #_list_0 do
      local instance = _list_0[_index_0]
      if instance:IsDownloading() then
        return 
      end
    end
    local _list_1 = self.PENDING
    for _index_0 = 1, #_list_1 do
      local instance = _list_1[_index_0]
      if instance:IsWaiting() then
        instance:Download()
        return 
      end
    end
  end
  VLL2.LargeFileLoader = _class_0
  return _class_0
end
end)
if not ___status then
	VLL2.Message('STARTUP FAILURE AT UTIL: ', ___err)
end
___status, ___err = pcall(function()
local string, table, VLL2
do
  local _obj_0 = _G
  string, table, VLL2 = _obj_0.string, _obj_0.table, _obj_0.VLL2
end
local type = luatype or type
do
  local _class_0
  local _base_0 = {
    Open = function(self, directory, lowered)
      if directory == '' or directory == '/' or directory:Trim() == '' then
        return self
      end
      if not lowered then
        directory = directory:lower()
      end
      do
        local startpos = string.find(directory, '/', 1, true)
        if startpos then
          local namedir = string.sub(directory, 1, startpos - 1)
          local nextdir = string.sub(directory, startpos + 1)
          if self.subdirs[namedir] then
            return self.subdirs[namedir]:Open(nextdir)
          end
          local dir = VLL2.FSDirectory(namedir, self)
          self.subdirs[namedir] = dir
          return dir:Open(nextdir, true)
        else
          if self.subdirs[directory] then
            return self.subdirs[directory]
          end
          local dir = VLL2.FSDirectory(directory, self)
          self.subdirs[directory] = dir
          return dir
        end
      end
    end,
    OpenRaw = function(self, directory, lowered)
      if directory == '' or directory == '/' or directory:Trim() == '' then
        return self
      end
      if not lowered then
        directory = directory:lower()
      end
      do
        local startpos = string.find(directory, '/', 1, true)
        if startpos then
          local namedir = string.sub(directory, 1, startpos - 1)
          local nextdir = string.sub(directory, startpos + 1)
          if self.subdirs[namedir] then
            return self.subdirs[namedir]:OpenRaw(nextdir, true)
          end
          return false
        else
          if self.subdirs[directory] then
            return self.subdirs[directory]
          end
          return false
        end
      end
    end,
    GetName = function(self)
      return self.name
    end,
    Write = function(self, name, contents)
      assert(type(name) == 'string', 'Invalid path type - ' .. type(name))
      assert(not string.find(name, '/', 1, true), 'Name should not contain slashes (/)')
      self.files[name:lower()] = contents
      return self
    end,
    Read = function(self, name)
      assert(type(name) == 'string', 'Invalid path type - ' .. type(name))
      assert(not string.find(name, '/', 1, true), 'Name should not contain slashes (/)')
      return self.files[name:lower()]
    end,
    Exists = function(self, name)
      assert(type(name) == 'string', 'Invalid path type - ' .. type(name))
      assert(not string.find(name, '/', 1, true), 'Name should not contain slashes (/)')
      return self.files[name:lower()] ~= nil
    end,
    ConstructFullPath = function(self)
      if not self.parent then
        return self.name .. '/'
      end
      return self.parent:ConstructFullPath() .. self.name .. '/'
    end,
    ListFiles = function(self)
      local arr
      do
        local _accum_0 = { }
        local _len_0 = 1
        for fil in pairs(self.files) do
          _accum_0[_len_0] = fil
          _len_0 = _len_0 + 1
        end
        arr = _accum_0
      end
      table.sort(arr)
      return arr
    end,
    ListDirs = function(self)
      local arr
      do
        local _accum_0 = { }
        local _len_0 = 1
        for _, fil in pairs(self.subdirs) do
          _accum_0[_len_0] = fil:GetName()
          _len_0 = _len_0 + 1
        end
        arr = _accum_0
      end
      table.sort(arr)
      return arr
    end,
    List = function(self)
      local arr = self:ListFiles()
      for fil in ipairs(self:ListDirs()) do
        table.insert(fil)
      end
      table.sort(arr)
      return arr
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, name, parent)
      self.name = name:lower()
      self.parent = parent
      self.subdirs = { }
      self.files = { }
    end,
    __base = _base_0,
    __name = "FSDirectory"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  VLL2.FSDirectory = _class_0
end
local splice
splice = function(arrIn, fromPos, deleteCount)
  if fromPos == nil then
    fromPos = 1
  end
  if deleteCount == nil then
    deleteCount = 2
  end
  local copy = { }
  for i = 1, fromPos - 1 do
    table.insert(copy, arrIn[i])
  end
  for i = fromPos + deleteCount, #arrIn do
    table.insert(copy, arrIn[i])
  end
  for i, val in ipairs(copy) do
    arrIn[i] = val
  end
  for i = #copy + 1, #arrIn do
    arrIn[i] = nil
  end
  return arrIn
end
do
  local _class_0
  local _base_0 = {
    Write = function(self, path, contents)
      assert(type(path) == 'string', 'Invalid path to write - ' .. type(path))
      assert(type(contents) == 'string', 'Contents must be a string - ' .. type(contents))
      assert(not string.find(path, '..', 1, true), 'Path must be absolute')
      local dname, fname = VLL2.FileSystem.StripFileName(path:lower())
      local dir = self.root:Open(dname, true)
      dir:Write(fname, contents)
      return self
    end,
    Read = function(self, path)
      assert(type(path) == 'string', 'Invalid path to write - ' .. type(path))
      assert(not string.find(path, '..', 1, true), 'Path must be absolute')
      local dname, fname = VLL2.FileSystem.StripFileName(path:lower())
      local dir = self.root:Open(dname, true)
      return dir:Read(fname)
    end,
    Exists = function(self, path)
      assert(type(path) == 'string', 'Invalid path to write - ' .. type(path))
      assert(not string.find(path, '..', 1, true), 'Path must be absolute')
      local dname, fname = VLL2.FileSystem.StripFileName(path:lower())
      return self.root:Open(dname, true):Exists(fname)
    end,
    Find = function(self, pattern)
      assert(type(pattern) == 'string', 'Invalid pattern type provided: ' .. type(pattern))
      assert(not string.find(pattern, '..', 1, true), 'Path must be absolute')
      local dname, fname = VLL2.FileSystem.StripFileName(pattern:lower())
      local dir = self.root:Open(dname, true)
      if fname == '*' then
        return dir:ListFiles(), dir:ListDirs()
      end
      local fpattern = VLL2.FileSystem.ToPattern(fname)
      local result
      do
        local _accum_0 = { }
        local _len_0 = 1
        local _list_0 = dir:ListFiles()
        for _index_0 = 1, #_list_0 do
          local fil = _list_0[_index_0]
          if string.find(fil, fpattern) then
            _accum_0[_len_0] = fil
            _len_0 = _len_0 + 1
          end
        end
        result = _accum_0
      end
      return result, dir:ListDirs()
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self)
      self.root = VLL2.FSDirectory('')
    end,
    __base = _base_0,
    __name = "FileSystem"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  local self = _class_0
  self.StripFileName = function(fname)
    local explode = string.Explode('/', fname)
    local filename = explode[#explode]
    explode[#explode] = nil
    return table.concat(explode, '/'), filename
  end
  self.ToPattern = function(fexp)
    return fexp:gsub('%.', '%%.'):gsub('%*', '.*')
  end
  self.Canonize = function(fpath)
    if not string.find(fpath, '..', 1, true) then
      return fpath
    end
    local starts = string.find(fpath, '..', 1, true)
    if starts == 1 then
      return 
    end
    local split
    do
      local _accum_0 = { }
      local _len_0 = 1
      for str in string.gmatch(fpath, '/') do
        _accum_0[_len_0] = str
        _len_0 = _len_0 + 1
      end
      split = _accum_0
    end
    local i = 0
    while true do
      i = i + 1
      local value = split[i]
      if not value then
        break
      end
      if value == '..' then
        if i == 1 then
          return 
        else
          splice(split, i - 1, 2)
          i = i - 2
        end
      end
    end
    return table.concat(split, '/')
  end
  VLL2.FileSystem = _class_0
end
VLL2.FileSystem.INSTANCE = VLL2.FileSystem()
end)
if not ___status then
	VLL2.Message('STARTUP FAILURE AT FILE SYSTEM: ', ___err)
end
___status, ___err = pcall(function()
local file, util, error, assert, HTTP, Entity, game
do
  local _obj_0 = _G
  file, util, error, assert, HTTP, Entity, game = _obj_0.file, _obj_0.util, _obj_0.error, _obj_0.assert, _obj_0.HTTP, _obj_0.Entity, _obj_0.game
end
local DO_DOWNLOAD_WORKSHOP
if SERVER then
  util.AddNetworkString('vll2.replicate_url')
  util.AddNetworkString('vll2.replicate_workshop')
  util.AddNetworkString('vll2.replicate_wscollection')
  util.AddNetworkString('vll2.replicate_all')
else
  DO_DOWNLOAD_WORKSHOP = CreateConVar('vll2_dl_workshop', '1', {
    FCVAR_ARCHIVE
  }, 'Actually download GMA files. Disabling this is VERY experemental, and can cause undesired behaviour of stuff. You were warned.')
  cvars.AddChangeCallback('vll2_dl_workshop', (function()
    return RunConsoleCommand('host_writeconfig')
  end), 'VLL2')
end
file.CreateDir('vll2')
file.CreateDir('vll2/ws_cache')
file.CreateDir('vll2/gma_cache')
sql.Query('CREATE TABLE IF NOT EXISTS vll2_lua_cache (fpath VARCHAR(400) PRIMARY KEY, tstamp BIGINT NOT NULL DEFAULT 0, contents BLOB NOT NULL)')
do
  local _class_0
  local _base_0 = {
    Msg = function(self, ...)
      return VLL2.MessageBundle(self.name .. ': ', ...)
    end,
    IsLoading = function(self)
      return self.status == self.__class.STATUS_LOADING
    end,
    IsLoaded = function(self)
      return self.status == self.__class.STATUS_LOADED
    end,
    IsRunning = function(self)
      return self.status == self.__class.STATUS_RUNNING
    end,
    IsErrored = function(self)
      return self.status == self.__class.STATUS_ERROR
    end,
    IsIdle = function(self)
      return self.status == self.__class.STATUS_NONE
    end,
    IsReplicated = function(self)
      return self.replicated
    end,
    SetInitAfterLoad = function(self, status)
      if status == nil then
        status = self.initAfterLoad
      end
      self.initAfterLoad = status
      return self
    end,
    DoInitAfterLoad = function(self)
      return self:SetInitAfterLoad(true)
    end,
    DoNotInitAfterLoad = function(self)
      return self:SetInitAfterLoad(true)
    end,
    AddLoadedHook = function(self, fcall)
      if self:IsRunning() then
        fcall(self)
        return self
      end
      table.insert(self.loadCallbacks, fcall)
      return self
    end,
    AddFinishHook = function(self, fcall)
      if self:IsRunning() then
        fcall(self)
        return self
      end
      table.insert(self.finishCallbacks, fcall)
      return self
    end,
    AddErrorHook = function(self, fcall)
      if self:IsErrored() then
        fcall(self)
        return self
      end
      table.insert(self.errorCallbacks, fcall)
      return self
    end,
    CallError = function(self, ...)
      local _list_0 = self.errorCallbacks
      for _index_0 = 1, #_list_0 do
        local fcall = _list_0[_index_0]
        fcall(self, ...)
      end
    end,
    CallFinish = function(self, ...)
      local _list_0 = self.finishCallbacks
      for _index_0 = 1, #_list_0 do
        local fcall = _list_0[_index_0]
        fcall(self, ...)
      end
    end,
    CallLoaded = function(self, ...)
      local _list_0 = self.loadCallbacks
      for _index_0 = 1, #_list_0 do
        local fcall = _list_0[_index_0]
        fcall(self, ...)
      end
    end,
    DoNotReplicate = function(self)
      self.replicated = false
      return self
    end,
    DoReplicate = function(self)
      self.replicated = true
      return self
    end,
    SetReplicate = function(self, status)
      if status == nil then
        status = self.replicated
      end
      self.replicated = status
      return self
    end,
    Replicate = function(self, ply)
      if ply == nil then
        ply = player.GetAll()
      end
      if CLIENT then
        return 
      end
      return error('Not implemented')
    end,
    Run = function(self)
      local vm = VLL2.VM(self.name, self.fs, VLL2.FileSystem.INSTANCE)
      vm:LoadAutorun()
      vm:LoadEntities()
      vm:LoadWeapons()
      if CLIENT then
        vm:LoadEffects()
      end
      vm:LoadToolguns()
      vm:LoadTFA()
      self:Msg('Bundle successfully initialized!')
      return self:CallFinish()
    end,
    Load = function(self)
      return error('Not implemented')
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, name)
      self.name = name
      self.__class._S[name] = self
      self.__class.LISTING[name] = self
      self.status = self.__class.STATUS_NONE
      self.fs = VLL2.FileSystem()
      self.globalFS = VLL2.FileSystem.INSTANCE
      self.initAfterLoad = true
      self.replicated = true
      self.errorCallbacks = { }
      self.finishCallbacks = { }
      self.loadCallbacks = { }
    end,
    __base = _base_0,
    __name = "AbstractBundle"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  local self = _class_0
  self._S = { }
  self.LISTING = { }
  self.STATUS_NONE = 0
  self.STATUS_LOADING = 1
  self.STATUS_LOADED = 2
  self.STATUS_RUNNING = 3
  self.STATUS_ERROR = 4
  self.Checkup = function(self, bname)
    if not self._S[bname] then
      return true
    end
    return not self._S[bname]:IsLoading()
  end
  self.FromCache = function(self, fname, fstamp)
    if not fstamp then
      local data = sql.Query('SELECT contents FROM vll2_lua_cache WHERE fpath = ' .. SQLStr(fname))
      if not data then
        return 
      end
      return data[1].contents
    end
    local data = sql.Query('SELECT contents FROM vll2_lua_cache WHERE tstamp >= ' .. fstamp .. ' AND fpath = ' .. SQLStr(fname))
    if not data then
      return 
    end
    return data[1].contents
  end
  self.FromCacheMultiple = function(self, fnames, fstamp)
    local format = '(' .. table.concat((function()
      local _accum_0 = { }
      local _len_0 = 1
      for _index_0 = 1, #fnames do
        local name = fnames[_index_0]
        _accum_0[_len_0] = SQLStr(name)
        _len_0 = _len_0 + 1
      end
      return _accum_0
    end)(), ',') .. ')'
    if not fstamp then
      return sql.Query('SELECT fpath, contents FROM vll2_lua_cache WHERE fpath IN  ' .. format) or { }
    end
    return sql.Query('SELECT fpath, contents FROM vll2_lua_cache WHERE tstamp >= ' .. fstamp .. ' AND fpath IN ' .. format) or { }
  end
  self.WriteCache = function(self, fname, contents, fstamp)
    if fstamp == nil then
      fstamp = os.time()
    end
    sql.Query('DELETE FROM vll2_lua_cache WHERE fpath = ' .. SQLStr(fname))
    return sql.Query('INSERT INTO vll2_lua_cache (fpath, tstamp, contents) VALUES (' .. SQLStr(fname) .. ', ' .. SQLStr(fstamp) .. ', ' .. SQLStr(contents) .. ')')
  end
  VLL2.AbstractBundle = _class_0
end
do
  local _class_0
  local _parent_0 = VLL2.AbstractBundle
  local _base_0 = {
    Replicate = function(self, ply)
      if ply == nil then
        ply = player.GetAll()
      end
      if CLIENT then
        return 
      end
      if player.GetHumans() == 0 then
        return 
      end
      net.Start('vll2.replicate_url')
      net.WriteString(self.name)
      return net.Send(ply)
    end,
    CheckIfRunnable = function(self)
      if self.toDownload == -1 then
        return 
      end
      if self.toDownload > self.downloaded then
        return 
      end
      self.status = self.__class.STATUS_LOADED
      self:Msg('Bundle got downloaded')
      self:CallLoaded()
      if not self.initAfterLoad then
        return 
      end
      return self:Run()
    end,
    DownloadFile = function(self, fpath, url)
      if SERVER and self.cDownloading >= 16 or CLIENT and self.cDownloading >= 48 then
        table.insert(self.downloadQueue, {
          fpath,
          url
        })
        return 
      end
      self:DownloadNextFile(fpath, url)
      return self
    end,
    __DownloadCallback = function(self)
      if #self.downloadQueue == 0 then
        return 
      end
      local fpath, url
      do
        local _obj_0 = table.remove(self.downloadQueue)
        fpath, url = _obj_0[1], _obj_0[2]
      end
      return self:DownloadNextFile(fpath, url)
    end,
    DownloadNextFile = function(self, fpath, url)
      assert(fpath)
      assert(url)
      self.cDownloading = self.cDownloading + 1
      local req = {
        method = 'GET',
        url = url:gsub(' ', '%%20'),
        headers = {
          ['User-Agent'] = 'VLL2',
          Referer = VLL2.Referer()
        }
      }
      req.failed = function(reason)
        if reason == nil then
          reason = 'failed'
        end
        self.cDownloading = self.cDownloading - 1
        self:__DownloadCallback()
        self.status = self.__class.STATUS_ERROR
        self:Msg('download of ' .. fpath .. ' failed, reason: ' .. reason)
        self:Msg('URL: ' .. url)
        return self:CallError()
      end
      req.success = function(code, body, headers)
        if code == nil then
          code = 400
        end
        if body == nil then
          body = ''
        end
        self.cDownloading = self.cDownloading - 1
        if code ~= 200 then
          self:Msg('download of ' .. fpath .. ' failed, server returned: ' .. code)
          self:Msg('URL: ' .. url)
          self.status = self.__class.STATUS_ERROR
          self:__DownloadCallback()
          self:CallError()
          return 
        end
        self.downloaded = self.downloaded + 1
        self:__DownloadCallback()
        self.fs:Write(fpath, body)
        self.globalFS:Write(fpath, body)
        self.__class:WriteCache(fpath, body)
        return self:CheckIfRunnable()
      end
      return HTTP(req)
    end,
    LoadFromList = function(self, bundle)
      if bundle == nil then
        bundle = self.bundleList
      end
      self.toDownload = #self.bundleList
      self.downloaded = 0
      local checkCache = { }
      local lines
      do
        local _accum_0 = { }
        local _len_0 = 1
        local _list_0 = self.bundleList
        for _index_0 = 1, #_list_0 do
          local line = _list_0[_index_0]
          if line ~= '' then
            _accum_0[_len_0] = string.Explode(';', line)
            _len_0 = _len_0 + 1
          end
        end
        lines = _accum_0
      end
      for _index_0 = 1, #lines do
        local _des_0 = lines[_index_0]
        local fpath, url, fstamp
        fpath, url, fstamp = _des_0[1], _des_0[2], _des_0[3]
        if not url then
          VLL2.MessageBundle(fpath, url, fstamp)
          error('wtf')
        end
        local hit = false
        for _index_1 = 1, #checkCache do
          local _des_1 = checkCache[_index_1]
          local stamp, listing
          stamp, listing = _des_1[1], _des_1[2]
          if stamp == fstamp then
            hit = true
            table.insert(listing, fpath)
          end
        end
        if not hit then
          table.insert(checkCache, {
            fstamp,
            {
              fpath
            }
          })
        end
      end
      local toload
      do
        local _accum_0 = { }
        local _len_0 = 1
        for _index_0 = 1, #lines do
          local _des_0 = lines[_index_0]
          local fpath, url
          fpath, url = _des_0[1], _des_0[2]
          _accum_0[_len_0] = {
            fpath,
            url
          }
          _len_0 = _len_0 + 1
        end
        toload = _accum_0
      end
      for _index_0 = 1, #checkCache do
        local _des_0 = checkCache[_index_0]
        local stamp, listing
        stamp, listing = _des_0[1], _des_0[2]
        local _list_0 = self.__class:FromCacheMultiple(listing, stamp)
        for _index_1 = 1, #_list_0 do
          local _des_1 = _list_0[_index_1]
          local fpath, contents
          fpath, contents = _des_1.fpath, _des_1.contents
          self.fs:Write(fpath, contents)
          self.globalFS:Write(fpath, contents)
          self.downloaded = self.downloaded + 1
          for i, entry in ipairs(toload) do
            if entry[1] == fpath then
              table.remove(toload, i)
              break
            end
          end
        end
      end
      for _index_0 = 1, #toload do
        local _des_0 = toload[_index_0]
        local fpath, url
        fpath, url = _des_0[1], _des_0[2]
        self:DownloadFile(fpath, url)
      end
      return self:CheckIfRunnable()
    end,
    Load = function(self)
      self.status = self.__class.STATUS_LOADING
      local req = {
        method = 'GET',
        url = self.__class.FETH_BUNDLE_URL .. '?r=' .. self.name,
        headers = {
          ['User-Agent'] = 'VLL2',
          Referer = VLL2.Referer()
        }
      }
      req.failed = function(reason)
        if reason == nil then
          reason = 'failed'
        end
        self.status = self.__class.STATUS_ERROR
        self.errReason = reason
        self:Msg('download of index file failed, reason: ' .. reason)
        return self:CallError()
      end
      req.success = function(code, body, headers)
        if code == nil then
          code = 400
        end
        if body == nil then
          body = ''
        end
        if code ~= 200 then
          self:Msg('download of index file failed, server returned: ' .. code)
          self.status = self.__class.STATUS_ERROR
          self:CallError()
          return 
        end
        self.bundleList = string.Explode('\n', body:Trim())
        self:Msg('Received index file, total ' .. #self.bundleList .. ' files to load')
        return self:LoadFromList()
      end
      HTTP(req)
      return self
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, name)
      _class_0.__parent.__init(self, name)
      self.toDownload = -1
      self.downloaded = -1
      self.downloadQueue = { }
      self.cDownloading = 0
    end,
    __base = _base_0,
    __name = "URLBundle",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  local self = _class_0
  self.FETH_BUNDLE_URL = 'https://dbotthepony.ru/vll/package.php'
  self.LISTING = { }
  self.GetMessage = function(self)
    if SERVER then
      return 
    end
    local downloading = 0
    for _, bundle in pairs(self.LISTING) do
      if bundle:IsLoading() then
        downloading = downloading + 1
      end
    end
    if downloading == 0 then
      return 
    end
    return 'VLL2 Is downloading ' .. downloading .. ' URL bundles'
  end
  if CLIENT then
    net.Receive('vll2.replicate_url', function()
      local graburl = net.ReadString()
      if not self:Checkup(graburl) then
        return 
      end
      VLL2.MessageBundle('Server requires URL bundle to be loaded: ' .. graburl)
      return VLL2.URLBundle(graburl):Load()
    end)
  end
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  VLL2.URLBundle = _class_0
end
do
  local _class_0
  local _parent_0 = VLL2.AbstractBundle
  local _base_0 = {
    IsGoingToMount = function(self)
      return self.status == self.__class.STATUS_GONNA_MOUNT
    end,
    DoLoadLua = function(self)
      return self:SetLoadLua(true)
    end,
    DoNotLoadLua = function(self)
      return self:SetLoadLua(false)
    end,
    SetLoadLua = function(self, status)
      if status == nil then
        status = self.loadLua
      end
      self.loadLua = status
      return self
    end,
    DoAddToSpawnMenu = function(self)
      return self:SetAddToSpawnMenu(true)
    end,
    DoNotAddToSpawnMenu = function(self)
      return self:SetAddToSpawnMenu(false)
    end,
    SetAddToSpawnMenu = function(self, status)
      if status == nil then
        status = self.addToSpawnMenu
      end
      self.addToSpawnMenu = status
      return self
    end,
    SpecifyPath = function(self, path)
      self.path = path
      self.validgma = file.Exists(path, 'GAME')
      return self
    end,
    Replicate = function(self, ply)
      if ply == nil then
        ply = player.GetAll()
      end
    end,
    Load = function(self)
      return self:Load()
    end,
    MountDelay = function(self)
      if self:IsGoingToMount() then
        return 
      end
      self.status = self.__class.STATUS_GONNA_MOUNT
      return timer.Simple(3, function()
        return self:Mount()
      end)
    end,
    Mount = function(self)
      if not self.path then
        error('Path was not specified earlier')
      end
      self.status = self.__class.STATUS_LOADING
      self:Msg('Mounting GMA from ' .. self.path)
      local status, filelist = game.MountGMA(self.path)
      if not status then
        self:Msg('Unable to mount gma!')
        self.status = self.__class.STATUS_ERROR
        self:CallError()
        return 
      end
      if #filelist == 0 then
        self:Msg('GMA IS EMPTY???!!!')
      end
      if self.loadLua then
        for _index_0 = 1, #filelist do
          local _file = filelist[_index_0]
          if string.sub(_file, 1, 3) == 'lua' then
            local fread = file.Read(_file, 'GAME')
            self.fs:Write(string.sub(_file, 5), fread)
            self.globalFS:Write(string.sub(_file, 5), fread)
          end
        end
        if self.initAfterLoad then
          self:Run()
        end
      end
      do
        local _accum_0 = { }
        local _len_0 = 1
        for _index_0 = 1, #filelist do
          local _file = filelist[_index_0]
          if string.sub(_file, 1, 6) == 'models' and string.sub(_file, -3) == 'mdl' then
            _accum_0[_len_0] = _file
            _len_0 = _len_0 + 1
          end
        end
        self.modelList = _accum_0
      end
      do
        local _accum_0 = { }
        local _len_0 = 1
        for _index_0 = 1, #filelist do
          local _file = filelist[_index_0]
          if string.sub(_file, 1, 9) == 'materials' then
            _accum_0[_len_0] = _file
            _len_0 = _len_0 + 1
          end
        end
        self.matList = _accum_0
      end
      self:Msg('Total assets: ', #filelist, ' including ', #self.modelList, ' models and ', #self.matList, ' materials')
      self.status = self.__class.STATUS_LOADED
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, name)
      _class_0.__parent.__init(self, name)
      self.validgma = false
      self.loadLua = true
      self.addToSpawnMenu = true
      self.modelList = { }
    end,
    __base = _base_0,
    __name = "GMABundle",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  local self = _class_0
  self.LISTING = { }
  self.STATUS_GONNA_MOUNT = 734
  self.GetMessage = function(self)
    if SERVER then
      return 
    end
    local msg1 = self:GetMessage1()
    local msg2 = self:GetMessage2()
    if not msg1 and not msg2 then
      return 
    end
    if msg1 and not msg2 then
      return msg1
    end
    if not msg1 and msg2 then
      return msg2
    end
    return {
      msg1,
      msg2
    }
  end
  self.GetMessage1 = function(self)
    if SERVER then
      return 
    end
    local downloading = 0
    for _, bundle in pairs(self.LISTING) do
      if bundle:IsLoading() then
        downloading = downloading + 1
      end
    end
    if downloading == 0 then
      return 
    end
    return 'VLL2 Is downloading ' .. downloading .. ' GMA bundles'
  end
  self.GetMessage2 = function(self)
    if SERVER then
      return 
    end
    local downloading = 0
    for _, bundle in pairs(self.LISTING) do
      if bundle:IsGoingToMount() then
        downloading = downloading + 1
      end
    end
    if downloading == 0 then
      return 
    end
    return 'VLL2 going to mount ' .. downloading .. ' GMA bundles\nFreeze (or crash) may occur\nthat\'s fine'
  end
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  VLL2.GMABundle = _class_0
end
do
  local _class_0
  local _parent_0 = VLL2.GMABundle
  local _base_0 = {
    SetMountAfterLoad = function(self, status)
      if status == nil then
        status = self.mountAfterLoad
      end
      self.mountAfterLoad = status
      return self
    end,
    DoMountAfterLoad = function(self)
      return self:SetMountAfterLoad(true)
    end,
    DoNotMountAfterLoad = function(self)
      return self:SetMountAfterLoad(false)
    end,
    __Mount = function(self)
      self.status = self.__class.STATUS_LOADED
      self:CallLoaded()
      if not self.mountAfterLoad then
        return 
      end
      return self:MountDelay()
    end,
    AfterLoad = function(self)
      if CLIENT and self.shouldNotifyServerside then
        net.Start('vll2.gma_notify_url')
        net.WriteString(self.url)
        net.WriteBool(true)
        net.SendToServer()
      end
      self:SpecifyPath(self._datapath_full)
      return self:__Mount()
    end,
    Load = function(self)
      if SERVER and not game.IsDedicated() then
        timer.Simple(1, function()
          net.Start('vll2.gma_notify_url')
          net.WriteString(self.url)
          net.WriteString(self._datapath)
          return net.Send(Entity(1))
        end)
        return 
      end
      if file.Exists(self._datapath, 'DATA') then
        self:Msg('Found GMA in cache, mounting in-place...')
        self:SpecifyPath(self._datapath_full)
        self:__Mount()
        return 
      end
      if CLIENT and not DO_DOWNLOAD_WORKSHOP:GetBool() then
        self:Msg('Not downloading workshop GMA file, since we have it disabled')
        self.status = self.__class.STATUS_ERROR
        self:CallError('Restricted by user')
        return 
      end
      self.status = self.__class.STATUS_LOADING
      self.gmadownloader = VLL2.LargeFileLoader(self.url, self._datapath)
      self.gmadownloader:AddFinishHook(function()
        return self:AfterLoad()
      end)
      self.gmadownloader:AddErrorHook(function(_, reason)
        if reason == nil then
          reason = 'failure'
        end
        if CLIENT and self.shouldNotifyServerside then
          net.Start('vll2.gma_notify_url')
          net.WriteString(self.url)
          net.WriteBool(false)
          net.SendToServer()
        end
        self.status = self.__class.STATUS_ERROR
        self:Msg('Failed to download the GMA! Reason: ' .. reason)
        return self:CallError()
      end)
      self:Msg('Downloading URL gma...')
      return self.gmadownloader:Load()
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, name, url)
      _class_0.__parent.__init(self, name)
      self.crc = util.CRC(url)
      self.url = url
      self._datapath = 'vll2/gma_cache/' .. self.crc .. '.dat'
      self._datapath_full = 'data/vll2/gma_cache/' .. self.crc .. '.dat'
      self.mountAfterLoad = true
    end,
    __base = _base_0,
    __name = "URLGMABundle",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  local self = _class_0
  if SERVER then
    util.AddNetworkString('vll2.gma_notify_url')
    net.Receive('vll2.gma_notify_url', function(len, ply)
      if len == nil then
        len = 0
      end
      if ply == nil then
        ply = NULL
      end
      if not ply:IsValid() then
        return 
      end
      if game.IsDedicated() then
        return 
      end
      if ply:EntIndex() ~= 1 then
        return 
      end
      local url = net.ReadString()
      local status = net.ReadBool()
      for name, self in pairs(self.LISTING) do
        if self.url == url then
          self:SpecifyPath(self._datapath_full)
          if status then
            self:AfterLoad(true)
          end
          if not status then
            self.status = self.__class.STATUS_ERROR
            self:Msg('Failed to download the GMA! Reason: ' .. reason)
            self:CallError()
          end
          return 
        end
      end
      VLL2.Message('Received URL bundle path from clientside, but no associated bundle found.')
      return VLL2.Message('W.T.F? URL is ' .. url)
    end)
  else
    net.Receive('vll2.gma_notify_url', function(len)
      if len == nil then
        len = 0
      end
      local url = net.ReadString()
      local _datapath = net.ReadString()
      for name, bundle in pairs(self.LISTING) do
        if bundle.url == url then
          if bundle.finished then
            net.Start('vll2.gma_notify_url')
            net.WriteString(url)
            net.WriteBool(true)
            net.SendToServer()
          else
            bundle.shouldNotifyServerside = true
          end
          return 
        end
      end
      local gmadownloader = VLL2.LargeFileLoader(url, _datapath)
      gmadownloader:AddFinishHook(function()
        net.Start('vll2.gma_notify_url')
        net.WriteString(url)
        net.WriteBool(true)
        return net.SendToServer()
      end)
      gmadownloader:AddErrorHook(function(_, reason)
        if reason == nil then
          reason = 'failure'
        end
        net.Start('vll2.gma_notify_url')
        net.WriteString(url)
        net.WriteBool(false)
        net.SendToServer()
        return VLL2.Message('Failed to download the GMA for server! Reason: ' .. reason)
      end)
      return gmadownloader:Load()
    end)
  end
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  VLL2.URLGMABundle = _class_0
end
do
  local _class_0
  local _parent_0 = VLL2.URLGMABundle
  local _base_0 = {
    AfterLoad = function(self, clientload)
      self:Msg('--- DECOMPRESSING')
      local stime = SysTime()
      local decompress = util.Decompress(file.Read(self._datapath, 'DATA'))
      if decompress == '' or not decompress then
        if SERVER and not game.IsDedicated() and clientload then
          self:SpecifyPath(self._datapath_full)
          self:__Mount()
          return 
        end
        self.status = self.__class.STATUS_ERROR
        self:Msg('Failed to decompress the GMA! Did tranfer got interrupted?')
        self:CallError()
        return 
      end
      self:Msg(string.format('Decompression took %.2f ms', (SysTime() - stime) * 1000))
      stime = SysTime()
      self:Msg('--- WRITING')
      file.Write(self._datapath, decompress)
      self:Msg(string.format('Writing to disk took %.2f ms', (SysTime() - stime) * 1000))
      self:SpecifyPath(self._datapath_full)
      return self:__Mount()
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, ...)
      return _class_0.__parent.__init(self, ...)
    end,
    __base = _base_0,
    __name = "URLGMABundleZ",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  VLL2.URLGMABundleZ = _class_0
end
do
  local _class_0
  local _parent_0 = VLL2.AbstractBundle
  local _base_0 = {
    Replicate = function(self, ply)
      if ply == nil then
        ply = player.GetAll()
      end
      if CLIENT then
        return 
      end
      if player.GetHumans() == 0 then
        return 
      end
      net.Start('vll2.replicate_wscollection')
      net.WriteUInt(self.workshopID, 32)
      net.WriteBool(self.loadLua)
      net.WriteBool(self.mountAfterLoad)
      return net.Send(ply)
    end,
    SetMountAfterLoad = function(self, status)
      if status == nil then
        status = self.mountAfterLoad
      end
      self.mountAfterLoad = status
      return self
    end,
    DoMountAfterLoad = function(self)
      return self:SetMountAfterLoad(true)
    end,
    DoNotMountAfterLoad = function(self)
      return self:SetMountAfterLoad(false)
    end,
    IsGettingInfo = function(self)
      return self.status == self.__class.STATUS_GETTING_INFO
    end,
    DoLoadLua = function(self)
      return self:SetLoadLua(true)
    end,
    DoNotLoadLua = function(self)
      return self:SetLoadLua(false)
    end,
    SetLoadLua = function(self, status)
      if status == nil then
        status = self.loadLua
      end
      self.loadLua = status
      return self
    end,
    Mount = function(self)
      self:Msg('GOING TO MOUNT WORKSHOP COLLECTION RIGHT NOW')
      local _list_0 = self.gmaListing
      for _index_0 = 1, #_list_0 do
        local fbundle = _list_0[_index_0]
        fbundle:Mount()
      end
      self.status = self.__class.STATUS_RUNNING
      self:Msg('Workshop collection initialized!')
      return self:CallFinish()
    end,
    OnAddonLoads = function(self, ...)
      local _list_0 = self.gmaListing
      for _index_0 = 1, #_list_0 do
        local fbundle = _list_0[_index_0]
        if not fbundle:IsLoaded() then
          return 
        end
      end
      self.status = self.__class.STATUS_LOADED
      self:CallLoaded()
      if not self.mountAfterLoad then
        return 
      end
      return self:Mount()
    end,
    OnAddonFails = function(self, fbundle, str, code, ...)
      if code == VLL2.WSBundle.INVALID_WS_DATA then
        for i, fbundle2 in ipairs(self.gmaListing) do
          if fbundle == fbundle2 then
            table.remove(self.gmaListing, i)
          end
        end
        self:OnAddonLoads()
        return 
      end
      self.status = self.__class.STATUS_ERROR
      self:Msg('One of collection addons has failed to load! Uh oh!')
      return self:CallError(str, code, ...)
    end,
    GetCollectionDetails = function(self)
      self.status = self.__class.STATUS_LOADING
      self.gmaListing = { }
      self.status = self.__class.STATUS_GETTING_INFO
      local req = {
        method = 'POST',
        url = self.__class.COLLECTION_INFO_URL,
        parameters = {
          collectioncount = '1',
          ['publishedfileids[0]'] = tostring(self.workshopID)
        },
        headers = {
          ['User-Agent'] = 'VLL2',
          Referer = VLL2.Referer()
        }
      }
      req.failed = function(reason)
        if reason == nil then
          reason = 'failure'
        end
        self.status = self.__class.STATUS_ERROR
        self:Msg('Failed to grab collection info! Reason: ' .. reason)
        return self:CallError()
      end
      req.success = function(code, body, headers)
        if code == nil then
          code = 400
        end
        if body == nil then
          body = ''
        end
        if code ~= 200 then
          self.status = self.__class.STATUS_ERROR
          self:Msg('Failed to grab collection info! Server returned: ' .. code)
          self:Msg(body)
          self:CallError()
          return 
        end
        local resp = util.JSONToTable(body)
        self.steamResponse = resp
        self.steamResponseRaw = body
        self.status = self.__class.STATUS_LOADING
        if resp and resp.response and resp.response.result == 1 and resp.response.collectiondetails and resp.response.collectiondetails[1] and resp.response.collectiondetails[1].result == 1 and resp.response.collectiondetails[1].children then
          local _list_0 = resp.response.collectiondetails[1].children
          for _index_0 = 1, #_list_0 do
            local item = _list_0[_index_0]
            local fbundle = VLL2.WSBundle(item.publishedfileid)
            fbundle:DoNotMountAfterLoad()
            fbundle:DoNotReplicate()
            fbundle:SetLoadLua(self.loadLua)
            fbundle:Load()
            fbundle:AddLoadedHook(function(_, ...)
              return self:OnAddonLoads(...)
            end)
            fbundle:AddErrorHook(function(_, ...)
              return self:OnAddonFails(_, ...)
            end)
            table.insert(self.gmaListing, fbundle)
          end
        else
          self.status = self.__class.STATUS_ERROR
          return self:Msg('Failed to grab collection info! Server did not sent valid reply or collection contains no items')
        end
      end
      return HTTP(req)
    end,
    GetWorkshopDetails = function(self)
      self.status = self.__class.STATUS_GETTING_INFO
      local req = {
        method = 'POST',
        url = self.__class.INFO_URL,
        parameters = {
          itemcount = '1',
          ['publishedfileids[0]'] = tostring(self.workshopID)
        },
        headers = {
          ['User-Agent'] = 'VLL2',
          Referer = VLL2.Referer()
        }
      }
      req.failed = function(reason)
        if reason == nil then
          reason = 'failure'
        end
        self.status = self.__class.STATUS_ERROR
        self:Msg('Failed to grab GMA info! Reason: ' .. reason)
        return self:CallError()
      end
      req.success = function(code, body, headers)
        if code == nil then
          code = 400
        end
        if body == nil then
          body = ''
        end
        if code ~= 200 then
          self.status = self.__class.STATUS_ERROR
          self:Msg('Failed to grab GMA info! Server returned: ' .. code)
          self:Msg(body)
          self:CallError()
          return 
        end
        local resp = util.JSONToTable(body)
        self.steamResponse = resp
        self.steamResponseRaw = body
        if resp and resp.response and resp.response.publishedfiledetails then
          local _list_0 = resp.response.publishedfiledetails
          for _index_0 = 1, #_list_0 do
            local item = _list_0[_index_0]
            if VLL2.WSBundle.IsAddonMounted(item.publishedfileid) and not self.loadLua then
              self.status = self.__class.STATUS_LOADED
              self:Msg('Addon ' .. item.title .. ' is already mounted and running')
            elseif item.hcontent_file and item.title then
              self:Msg('GOT FILEINFO DETAILS FOR ' .. self.workshopID .. ' (' .. item.title .. ')')
              self.steamworksInfo = item
              self.wsTitle = item.title
              self.name = item.title
              if tobool(item.banned) then
                self:Msg('-----------------------------')
                self:Msg('--- This workshop item was BANNED!')
                self:Msg('--- Ban reason: ' .. (item.ban_reason or '<unknown>'))
                self:Msg('--- But the addon will still be mounted though')
                self:Msg('-----------------------------')
              end
              self:GetCollectionDetails()
            else
              self.status = self.__class.STATUS_ERROR
              self:Msg('This workshop item contains no valid data.')
              self:CallError('This workshop item contains no valid data.')
            end
          end
        else
          self.status = self.__class.STATUS_ERROR
          self:Msg('Failed to grab GMA info! Server did not sent valid reply')
          return self:CallError()
        end
      end
      return HTTP(req)
    end,
    Load = function(self)
      return self:GetWorkshopDetails()
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, name)
      _class_0.__parent.__init(self, name)
      self.workshopID = assert(tonumber(self.name), 'Unable to cast workshopid to number')
      self.mountAfterLoad = true
      self.gmaListing = { }
      self.loadLua = true
    end,
    __base = _base_0,
    __name = "WSCollection",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  local self = _class_0
  self.COLLECTION_INFO_URL = 'https://api.steampowered.com/ISteamRemoteStorage/GetCollectionDetails/v1/'
  self.INFO_URL = 'https://api.steampowered.com/ISteamRemoteStorage/GetPublishedFileDetails/v1/'
  self.LISTING = { }
  self.STATUS_GETTING_INFO = 621
  if CLIENT then
    net.Receive('vll2.replicate_wscollection', function()
      local graburl = net.ReadUInt(32)
      if not self:Checkup(graburl) then
        return 
      end
      local loadLua = net.ReadBool()
      local mountAfterLoad = net.ReadBool()
      VLL2.MessageBundle('Server requires workshop COLLECTION to be loaded: ' .. graburl)
      local bundle = VLL2.WSCollection(graburl)
      bundle.loadLua = loadLua
      bundle.mountAfterLoad = mountAfterLoad
      return bundle:Load()
    end)
  end
  self.GetMessage = function(self)
    if SERVER then
      return 
    end
    local msg1 = self:GetMessage1()
    local msg2 = self:GetMessage2()
    if not msg1 and not msg2 then
      return 
    end
    if msg1 and not msg2 then
      return msg1
    end
    if not msg1 and msg2 then
      return msg2
    end
    return {
      msg1,
      msg2
    }
  end
  self.GetMessage1 = function(self)
    if SERVER then
      return 
    end
    local downloading = 0
    for _, bundle in pairs(self.LISTING) do
      if bundle:IsLoading() then
        downloading = downloading + 1
      end
    end
    if downloading == 0 then
      return 
    end
    return 'VLL2 Is downloading ' .. downloading .. ' Workshop COLLECTIONS'
  end
  self.GetMessage2 = function(self)
    if SERVER then
      return 
    end
    local downloading = 0
    for _, bundle in pairs(self.LISTING) do
      if bundle:IsGettingInfo() then
        downloading = downloading + 1
      end
    end
    if downloading == 0 then
      return 
    end
    return 'Getting info of ' .. downloading .. ' workshop COLLECTIONS'
  end
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  VLL2.WSCollection = _class_0
end
do
  local _class_0
  local _parent_0 = VLL2.GMABundle
  local _base_0 = {
    SetMountAfterLoad = function(self, status)
      if status == nil then
        status = self.mountAfterLoad
      end
      self.mountAfterLoad = status
      return self
    end,
    DoMountAfterLoad = function(self)
      return self:SetMountAfterLoad(true)
    end,
    DoNotMountAfterLoad = function(self)
      return self:SetMountAfterLoad(false)
    end,
    IsGettingInfo = function(self)
      return self.status == self.__class.STATUS_GETTING_INFO
    end,
    __Mount = function(self)
      self.status = self.__class.STATUS_LOADED
      self:CallLoaded()
      if self.shouldNotifyServerside then
        net.Start('vll2.gma_notify')
        net.WriteUInt(self.workshopID, 32)
        net.WriteString(self.path)
        net.SendToServer()
        self:Msg('Notifying server realm that we downloaded GMA.')
        self.shouldNotifyServerside = false
      end
      if not self.mountAfterLoad then
        return 
      end
      return self:MountDelay()
    end,
    Mount = function(self, ...)
      if self.shouldNotifyServerside then
        net.Start('vll2.gma_notify')
        net.WriteUInt(self.workshopID, 32)
        net.WriteString(self.path)
        net.SendToServer()
        self:Msg('Notifying server realm that we downloaded GMA.')
        self.shouldNotifyServerside = false
      end
      return _class_0.__parent.__base.Mount(self, ...)
    end,
    Replicate = function(self, ply)
      if ply == nil then
        ply = player.GetAll()
      end
      if CLIENT then
        return 
      end
      if player.GetHumans() == 0 then
        return 
      end
      net.Start('vll2.replicate_workshop')
      net.WriteUInt(self.workshopID, 32)
      net.WriteBool(self.loadLua)
      net.WriteBool(self.addToSpawnMenu)
      return net.Send(ply)
    end,
    DownloadGMA = function(self, url, filename)
      if filename == nil then
        filename = util.CRC(url)
      end
      if CLIENT then
        local msgid = 'vll2_dl_' .. self.workshopID
        notification.AddProgress(msgid, 'Downloading ' .. data.title .. ' from workshop')
        self.status = self.__class.STATUS_LOADING
        steamworks.Download(data.fileid, true, function(path2)
          notification.Kill(msgid)
          self:Msg('Downloaded from workshop')
          self:SpecifyPath(path2 or path)
          return self:__Mount()
        end)
        return 
      end
      local fdir, fname = VLL2.FileSystem.StripFileName(filename)
      local fadd = ''
      if fdir ~= '' then
        fadd = util.CRC(fdir) .. '_'
      end
      local fpath = 'vll2/ws_cache/' .. fadd .. fname .. '.dat'
      if file.Exists(fpath, 'DATA') then
        self:Msg('Found GMA in cache, mounting in-place...')
        self:SpecifyPath('data/' .. fpath)
        self:__Mount()
        return 
      end
      if not game.IsDedicated() then
        self:Msg('Singleplayer detected, waiting for client realm to download...')
        timer.Simple(1, function()
          net.Start('vll2.gma_notify')
          net.WriteUInt(self.workshopID, 32)
          net.WriteString(self.hcontent_file)
          return net.Send(Entity(1))
        end)
        return 
      end
      self.gmadownloader = VLL2.LargeFileLoader(url, fpath)
      self.gmadownloader:AddFinishHook(function()
        self:Msg('--- DECOMPRESSING')
        local stime = SysTime()
        local decompress = util.Decompress(file.Read(fpath, 'DATA'))
        if decompress == '' then
          self.status = self.__class.STATUS_ERROR
          self:Msg('Failed to decompress the GMA! Did tranfer got interrupted?')
          self:CallError()
          return 
        end
        self:Msg(string.format('Decompression took %.2f ms', (SysTime() - stime) * 1000))
        stime = SysTime()
        self:Msg('--- WRITING')
        file.Write(fpath, decompress)
        self:Msg(string.format('Writing to disk took %.2f ms', (SysTime() - stime) * 1000))
        self:SpecifyPath('data/' .. fpath)
        return self:__Mount()
      end)
      self.gmadownloader:AddErrorHook(function(_, reason)
        if reason == nil then
          reason = 'failure'
        end
        self.status = self.__class.STATUS_ERROR
        self:Msg('Failed to download the GMA! Reason: ' .. reason)
        return self:CallError()
      end)
      self:Msg('Downloading ' .. self.wsTitle .. '...')
      return self.gmadownloader:Load()
    end,
    Load = function(self)
      self.status = self.__class.STATUS_LOADING
      if CLIENT and steamworks.IsSubscribed(tostring(id)) and not self.loadLua then
        self:Msg('Not downloading addon ' .. id .. ' since it is already mounted on client.')
        self.status = self.__class.STATUS_LOADED
        return 
      end
      if CLIENT then
        self.status = self.__class.STATUS_GETTING_INFO
        local req = {
          method = 'POST',
          url = self.__class.INFO_URL,
          parameters = {
            itemcount = '1',
            ['publishedfileids[0]'] = tostring(self.workshopID)
          },
          headers = {
            ['User-Agent'] = 'VLL2',
            Referer = VLL2.Referer()
          }
        }
        req.failed = function(reason)
          if reason == nil then
            reason = 'failure'
          end
          self.status = self.__class.STATUS_ERROR
          self:Msg('Failed to grab GMA info! Reason: ' .. reason)
          return self:CallError()
        end
        req.success = function(code, body, headers)
          if code == nil then
            code = 400
          end
          if body == nil then
            body = ''
          end
          if code ~= 200 then
            self.status = self.__class.STATUS_ERROR
            self:Msg('Failed to grab GMA info! Server returned: ' .. code)
            self:Msg(body)
            self:CallError()
            return 
          end
          local resp = util.JSONToTable(body)
          self.steamResponse = resp
          self.steamResponseRaw = body
          if resp and resp.response and resp.response.publishedfiledetails then
            local _list_0 = resp.response.publishedfiledetails
            for _index_0 = 1, #_list_0 do
              local item = _list_0[_index_0]
              if VLL2.WSBundle.IsAddonMounted(item.publishedfileid) and not self.loadLua then
                self.status = self.__class.STATUS_LOADED
                self:Msg('Addon ' .. item.title .. ' is already mounted and running')
              elseif item.hcontent_file and item.title then
                self:Msg('GOT FILEINFO DETAILS FOR ' .. self.workshopID .. ' (' .. item.title .. ')')
                local path = 'cache/workshop/' .. item.hcontent_file .. '.cache'
                self.steamworksInfo = item
                self.wsTitle = item.title
                self.name = item.title
                self.hcontent_file = item.hcontent_file
                if tobool(item.banned) then
                  self:Msg('-----------------------------')
                  self:Msg('--- This workshop item was BANNED!')
                  self:Msg('--- Ban reason: ' .. (item.ban_reason or '<unknown>'))
                  self:Msg('--- But the addon will still be mounted though')
                  self:Msg('-----------------------------')
                end
                if file.Exists(path, 'GAME') then
                  self:SpecifyPath(path)
                  self:__Mount()
                elseif not DO_DOWNLOAD_WORKSHOP:GetBool() then
                  self:Msg('Not downloading workshop GMA file, since we have it disabled')
                  self.status = self.__class.STATUS_ERROR
                  self:CallError('Restricted by user')
                else
                  self:Msg('Downloading from workshop')
                  local msgid = 'vll2_dl_' .. self.workshopID
                  notification.AddProgress(msgid, 'Downloading ' .. item.title .. ' from workshop')
                  self.status = self.__class.STATUS_LOADING
                  steamworks.Download(item.hcontent_file, true, function(path2)
                    notification.Kill(msgid)
                    self:Msg('Downloaded from workshop')
                    self:SpecifyPath(path2 or path)
                    self.wscontentPath = path2 or path
                    if self.shouldNotifyServerside then
                      net.Start('vll2.gma_notify')
                      net.WriteUInt(self.workshopID, 32)
                      net.WriteString(path2 or path)
                      net.SendToServer()
                      self:Msg('Notifying server realm that we downloaded GMA.')
                      self.shouldNotifyServerside = false
                    end
                    return self:__Mount()
                  end)
                end
              else
                self.status = self.__class.STATUS_ERROR
                self:Msg('This workshop item contains no valid data.')
                self:CallError('This workshop item contains no valid data.', self.__class.INVALID_WS_DATA)
              end
            end
          else
            self.status = self.__class.STATUS_ERROR
            self:Msg('Failed to grab GMA info! Server did not sent valid reply')
            return self:CallError()
          end
        end
        return HTTP(req)
      else
        self.status = self.__class.STATUS_GETTING_INFO
        local req = {
          method = 'POST',
          url = self.__class.INFO_URL,
          parameters = {
            itemcount = '1',
            ['publishedfileids[0]'] = tostring(self.workshopID)
          },
          headers = {
            ['User-Agent'] = 'VLL2',
            Referer = VLL2.Referer()
          }
        }
        req.failed = function(reason)
          if reason == nil then
            reason = 'failure'
          end
          self.status = self.__class.STATUS_ERROR
          self:Msg('Failed to grab GMA info! Reason: ' .. reason)
          return self:CallError()
        end
        req.success = function(code, body, headers)
          if code == nil then
            code = 400
          end
          if body == nil then
            body = ''
          end
          if code ~= 200 then
            self.status = self.__class.STATUS_ERROR
            self:Msg('Failed to grab GMA info! Server returned: ' .. code)
            self:Msg(body)
            self:CallError()
            return 
          end
          local resp = util.JSONToTable(body)
          self.steamResponse = resp
          self.steamResponseRaw = body
          if resp and resp.response and resp.response.publishedfiledetails then
            local _list_0 = resp.response.publishedfiledetails
            for _index_0 = 1, #_list_0 do
              local item = _list_0[_index_0]
              if VLL2.WSBundle.IsAddonMounted(item.publishedfileid) and not self.loadLua then
                self.status = self.__class.STATUS_LOADED
                self:Msg('Addon ' .. item.title .. ' is already mounted and running')
              elseif item.hcontent_file and item.title then
                self:Msg('GOT FILEINFO DETAILS FOR ' .. self.workshopID .. ' (' .. item.title .. ')')
                self.steamworksInfo = item
                self.wsTitle = item.title
                self.name = item.title
                self.hcontent_file = item.hcontent_file
                if tobool(item.banned) then
                  self:Msg('-----------------------------')
                  self:Msg('--- This workshop item was BANNED!')
                  self:Msg('--- Ban reason: ' .. (item.ban_reason or '<unknown>'))
                  self:Msg('--- But the addon will still be mounted though')
                  self:Msg('-----------------------------')
                end
                self:DownloadGMA(item.file_url, item.filename)
              else
                self.status = self.__class.STATUS_ERROR
                self:Msg('This workshop item contains no valid data.')
                self:CallError('This workshop item contains no valid data.')
              end
            end
          else
            self.status = self.__class.STATUS_ERROR
            self:Msg('Failed to grab GMA info! Server did not sent valid reply')
            return self:CallError()
          end
        end
        return HTTP(req)
      end
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, name)
      _class_0.__parent.__init(self, name)
      self.workshopID = assert(tonumber(self.name), 'Unable to cast workshopid to number')
      self.mountAfterLoad = true
    end,
    __base = _base_0,
    __name = "WSBundle",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  local self = _class_0
  self.INFO_URL = 'https://api.steampowered.com/ISteamRemoteStorage/GetPublishedFileDetails/v1/'
  self.LISTING = { }
  self.STATUS_GETTING_INFO = 5
  self.IsAddonMounted = function(addonid)
    if not addonid then
      return false
    end
    local _list_0 = engine.GetAddons()
    for _index_0 = 1, #_list_0 do
      local addon = _list_0[_index_0]
      if addon.mounted and addon.wsid == addonid then
        return true
      end
    end
    return false
  end
  self.GetMessage = function(self)
    if SERVER then
      return 
    end
    local msg1 = self:GetMessage1()
    local msg2 = self:GetMessage2()
    local msgOld = VLL2.GMABundle.GetMessage2(self)
    if not msg1 and not msg2 and not msgOld then
      return 
    end
    local output = { }
    if msg1 then
      table.insert(output, msg1)
    end
    if msg2 then
      table.insert(output, msg2)
    end
    if msgOld then
      table.insert(output, msgOld)
    end
    return output
  end
  self.GetMessage1 = function(self)
    if SERVER then
      return 
    end
    local downloading = 0
    for _, bundle in pairs(self.LISTING) do
      if bundle:IsLoading() then
        downloading = downloading + 1
      end
    end
    if downloading == 0 then
      return 
    end
    return 'VLL2 Is downloading ' .. downloading .. ' Workshop addons'
  end
  self.GetMessage2 = function(self)
    if SERVER then
      return 
    end
    local downloading = 0
    for _, bundle in pairs(self.LISTING) do
      if bundle:IsGettingInfo() then
        downloading = downloading + 1
      end
    end
    if downloading == 0 then
      return 
    end
    return 'Getting info of ' .. downloading .. ' workshop addons'
  end
  if CLIENT then
    net.Receive('vll2.replicate_workshop', function()
      local graburl = net.ReadUInt(32)
      if not self:Checkup(graburl) then
        return 
      end
      local loadLua = net.ReadBool()
      local addToSpawnMenu = net.ReadBool()
      VLL2.MessageBundle('Server requires workshop addon to be loaded: ' .. graburl)
      local bundle = VLL2.WSBundle(graburl)
      bundle.loadLua = loadLua
      bundle.addToSpawnMenu = addToSpawnMenu
      return bundle:Load()
    end)
  end
  if SERVER then
    util.AddNetworkString('vll2.gma_notify')
    net.Receive('vll2.gma_notify', function(len, ply)
      if len == nil then
        len = 0
      end
      if ply == nil then
        ply = NULL
      end
      if not ply:IsValid() then
        return 
      end
      if game.IsDedicated() then
        return 
      end
      if ply:EntIndex() ~= 1 then
        return 
      end
      local wsid = net.ReadUInt(32)
      local path = net.ReadString()
      for name, bundle in pairs(self.LISTING) do
        if bundle.workshopID == wsid then
          bundle:SpecifyPath(path)
          bundle:__Mount()
          return 
        end
      end
      VLL2.Message('Received bundle path from clientside, but no associated bundle found.')
      return VLL2.Message('W.T.F? Workshop id is ' .. wsid)
    end)
  else
    net.Receive('vll2.gma_notify', function(len)
      if len == nil then
        len = 0
      end
      local wsid = net.ReadUInt(32)
      local hcontent_file = net.ReadString()
      for name, bundle in pairs(self.LISTING) do
        if bundle.workshopID == wsid then
          if bundle.wscontentPath then
            net.Start('vll2.gma_notify')
            net.WriteUInt(wsid, 32)
            net.WriteString(bundle.wscontentPath)
            net.SendToServer()
            bundle:Msg('Notifying server realm that we already got GMA')
          else
            bundle.shouldNotifyServerside = true
            bundle:Msg('We are still downloading bundle. Will notify server realm when we are done.')
          end
          return 
        end
      end
      local msgid = 'vll2_dl_' .. wsid
      notification.AddProgress(msgid, 'Downloading ' .. wsid .. ' from workshop (SERVER)')
      VLL2.Message('Downloading addon for server realm: ' .. wsid)
      return steamworks.Download(hcontent_file, true, function(path)
        notification.Kill(msgid)
        net.Start('vll2.gma_notify')
        net.WriteUInt(wsid, 32)
        net.WriteString(path)
        return net.SendToServer()
      end)
    end)
  end
  self.INVALID_WS_DATA = 912
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  VLL2.WSBundle = _class_0
end
if SERVER then
  return net.Receive('vll2.replicate_all', function(len, ply)
    for _, bundle in pairs(VLL2.AbstractBundle._S) do
      if bundle:IsReplicated() then
        bundle:Replicate(ply)
      end
    end
  end)
else
  return timer.Simple(5, function()
    net.Start('vll2.replicate_all')
    return net.SendToServer()
  end)
end
end)
if not ___status then
	VLL2.Message('STARTUP FAILURE AT BUNDLE: ', ___err)
end
___status, ___err = pcall(function()
local getfenv, assert, error, rawset, setfenv
do
  local _obj_0 = _G
  getfenv, assert, error, rawset, setfenv = _obj_0.getfenv, _obj_0.assert, _obj_0.error, _obj_0.rawset, _obj_0.setfenv
end
local getvm
getvm = function()
  local fret = getfenv(3).VLL2_VM or getfenv(2).VLL2_VM or getfenv(4).VLL2_VM
  if not fret then
    VLL2.Message(getfenv(3), ' ', getfenv(2), ' ', getfenv(1))
    error('INVALID LEVEL OF CALL?!')
  end
  return fret
end
local getdef
getdef = function()
  local fret = getfenv(3).VLL2_FILEDEF or getfenv(4).VLL2_FILEDEF or getfenv(2).VLL2_FILEDEF
  if not fret then
    VLL2.Message(getfenv(3), ' ', getfenv(2), ' ', getfenv(1))
    error('INVALID LEVEL OF CALL?!')
  end
  return fret
end
VLL2.ENV_TEMPLATE = {
  AddCSLuaFile = function(fpath)
    if not fpath then
      return 
    end
    local def = getdef()
    if def:FindRelative(fpath) then
      return 
    end
    if file.Exists(fpath, 'LUA') then
      return 
    end
    local canonize = VLL2.FileSystem.Canonize(def:Dir(fpath))
    if file.Exists(canonize, 'LUA') then
      return 
    end
    return def:Msg('Unable to find specified file for AddCSLuaFile: ' .. fpath)
  end,
  module = function(moduleName, ...)
    assert(type(moduleName) == 'string', 'Invalid module name')
    local allowGlobals = false
    local mtab = _G[moduleName] or { }
    _G[moduleName] = mtab
    local _env = getfenv(1)
    local env = {
      VLL2_VM = getvm(),
      VLL2_FILEDEF = getdef(),
      __index = function(self, key)
        if mtab[key] ~= nil then
          return mtab[key]
        end
        if allowGlobals then
          return _env[key]
        end
        return rawget(self, key)
      end,
      __newindex = function(self, key, value)
        mtab[key] = value
      end
    }
    local _list_0 = {
      ...
    }
    for _index_0 = 1, #_list_0 do
      local fcall = _list_0[_index_0]
      if fcall == package.seeall then
        allowGlobals = true
      else
        fcall(mtab)
      end
    end
    return setfenv(1, env)
  end,
  setfenv = function(func, env)
    assert(type(env) == 'table', 'Invalid function environment')
    rawset(env, 'VLL2_VM', getvm())
    rawset(env, 'VLL2_FILEDEF', getdef())
    return setfenv(func, env)
  end,
  require = function(fpath)
    assert(type(fpath) == 'string', 'Invalid path')
    local vm = getvm()
    if vm:Exists('includes/modules/' .. fpath .. '.lua') then
      local fget, fstatus, ferror = vm:CompileFile(canonize or fpath)
      assert(fstatus, ferror, 2)
      return fget()
    else
      return require(fpath)
    end
  end,
  include = function(fpath)
    assert(type(fpath) == 'string', 'Invalid path')
    local vm = getvm()
    local def = getdef()
    assert(vm, 'Missing VM. File: ' .. fpath)
    assert(def, 'Missing file def. File: ' .. fpath)
    local canonize = def:FindRelative(fpath)
    vm:Msg('Running file ' .. (canonize or fpath))
    local fget, fstatus, ferror = vm:CompileFile(canonize or fpath)
    assert(fstatus, ferror)
    return fget()
  end,
  CompileFile = function(fpath)
    assert(type(fpath) == 'string', 'Invalid path')
    local vm = getvm()
    local def = getdef()
    local canonize = def:FindRelative(fpath)
    vm:Msg('Compiling file ' .. (canonize or fpath))
    local fget, fstatus, ferror = vm:CompileFile(canonize or fpath)
    assert(fstatus, ferror)
    return fget
  end,
  CompileString = function(strIn, identifier, handle)
    if handle == nil then
      handle = true
    end
    assert(identifier, 'Missing identifier', 2)
    local vm = getvm()
    local fget, fstatus, ferror = vm:CompileString(strIn, identifier, getdef())
    if not handle and not fstatus then
      return ferror
    end
    if handle and not fstatus then
      error(ferror, 2)
    end
    return fget
  end,
  RunString = function(strIn, identifier, handle)
    if identifier == nil then
      identifier = 'RunString'
    end
    if handle == nil then
      handle = true
    end
    local vm = getvm()
    local fget, fstatus, ferror = vm:CompileString(strIn, identifier, getdef())
    if not handle and not fstatus then
      return ferror
    end
    if handle and not fstatus then
      error(ferror, 2)
    end
    fget()
    return nil
  end
}
local rawget, file
do
  local _obj_0 = _G
  rawget, file = _obj_0.rawget, _obj_0.file
end
VLL2.ENV_TEMPLATE.file = {
  Exists = function(fpath, fmod)
    assert(fmod, 'Invalid FMOD provided')
    if fmod:lower() ~= 'lua' then
      return file.Exists(fpath, fmod)
    end
    return getdef():FileExists(fpath) or file.Exists(fpath, fmod)
  end,
  Read = function(fpath, fmod)
    if fmod == nil then
      fmod = 'DATA'
    end
    if fmod:lower() ~= 'lua' then
      return file.Read(fpath, fmod)
    end
    return getdef():ReadFile(fpath)
  end,
  Find = function(fpath, fmod)
    assert(fmod, 'Invalid FMOD provided')
    if fmod:lower() ~= 'lua' then
      return file.Find(fpath, fmod)
    end
    return getdef():FindFiles(fpath)
  end,
  IsDir = function(fpath, fmod)
    assert(fmod, 'Invalid FMOD provided')
    if fmod:lower() ~= 'lua' then
      return file.IsDir(fpath, fmod)
    end
    return getdef():IsDir(fpath)
  end
}
for k, v in pairs(file) do
  if VLL2.ENV_TEMPLATE.file[k] == nil then
    VLL2.ENV_TEMPLATE.file[k] = v
  end
end
return setmetatable(VLL2.ENV_TEMPLATE.file, {
  __index = file,
  __newindex = file
})
end)
if not ___status then
	VLL2.Message('STARTUP FAILURE AT VM DEFINITION: ', ___err)
end
___status, ___err = pcall(function()
local _G = _G
local include, getfenv, setfenv, rawget, setmetatable
include, getfenv, setfenv, rawget, setmetatable = _G.include, _G.getfenv, _G.setfenv, _G.rawget, _G.setmetatable
local includes
includes = function(self, val)
  local _list_0 = self
  for _index_0 = 1, #_list_0 do
    local val2 = _list_0[_index_0]
    if val == val2 then
      return true
    end
  end
end
do
  local _class_0
  local _base_0 = {
    FileExists = function(self, fpath)
      return fpath and (self.localFS:Exists(fpath) or self.globalFS and self.globalFS:Exists(fpath) or file.Exists(fpath, 'LUA'))
    end,
    ReadFile = function(self, fpath)
      if not self:FileExists(fpath) then
        return ''
      end
      if self.localFS:Exists(fpath) then
        return self.localFS:Read(fpath)
      end
      if self.globalFS and self.globalFS:Exists(fpath) then
        return self.globalFS:Read(fpath)
      end
      return ''
    end,
    Dir = function(self, fpath)
      return self.dir .. '/' .. fpath
    end,
    FindRelative = function(self, fpath)
      local canonize = VLL2.FileSystem.Canonize(fpath)
      if self:FileExists(canonize) then
        return canonize
      end
      canonize = VLL2.FileSystem.Canonize(self.dir .. '/' .. fpath)
      if self:FileExists(canonize) then
        return canonize
      end
    end,
    FindFiles = function(self, fpath)
      local files, dirs = self.localFS:Find(fpath)
      if not self.globalFS then
        return files, dirs
      end
      local files2, dirs2 = self.globalFS:Find(fpath)
      local files3, dirs3 = file.Find(fpath, 'LUA')
      for _index_0 = 1, #files2 do
        local _file = files2[_index_0]
        if not includes(files, _file) then
          table.insert(files, _file)
        end
      end
      for _index_0 = 1, #dirs2 do
        local _dir = dirs2[_index_0]
        if not includes(dirs, _dir) then
          table.insert(dirs, _dir)
        end
      end
      for _index_0 = 1, #files3 do
        local _file = files3[_index_0]
        if not includes(files, _file) then
          table.insert(files, _file)
        end
      end
      for _index_0 = 1, #dirs3 do
        local _dir = dirs3[_index_0]
        if not includes(dirs, _dir) then
          table.insert(dirs, _dir)
        end
      end
      table.sort(files)
      table.sort(dirs)
      return files, dirs
    end,
    IsDir = function(self, fpath)
      return self.localFS:OpenRaw(fpath) ~= nil or self.globalFS and self.globalFS:OpenRaw(fpath) ~= nil
    end,
    Msg = function(self, ...)
      return VLL2.MessageVM(self.vm.vmName .. ':' .. self.fpath .. ':', ...)
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, fpath, vm)
      self.vm = vm
      self.fpath = fpath
      self.canonized = VLL2.FileSystem.Canonize(fpath)
      self.dir, self.fname = VLL2.FileSystem.StripFileName(fpath)
      self.localFS = self.vm.localFS
      self.globalFS = self.vm.globalFS
    end,
    __base = _base_0,
    __name = "FileDef"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  VLL2.FileDef = _class_0
end
do
  local _class_0
  local _base_0 = {
    LoadAutorun = function(self)
      local _list_0 = self.localFS:Find('dlib/autorun/*.lua')
      for _index_0 = 1, #_list_0 do
        local fil = _list_0[_index_0]
        self:RunFile('dlib/autorun/' .. fil)
      end
      if SERVER then
        local _list_1 = self.localFS:Find('dlib/autorun/server/*.lua')
        for _index_0 = 1, #_list_1 do
          local fil = _list_1[_index_0]
          self:RunFile('dlib/autorun/server/' .. fil)
        end
      end
      if CLIENT then
        local _list_1 = self.localFS:Find('dlib/autorun/client/*.lua')
        for _index_0 = 1, #_list_1 do
          local fil = _list_1[_index_0]
          self:RunFile('dlib/autorun/client/' .. fil)
        end
      end
      local _list_1 = self.localFS:Find('autorun/*.lua')
      for _index_0 = 1, #_list_1 do
        local fil = _list_1[_index_0]
        self:RunFile('autorun/' .. fil)
      end
      if SERVER then
        local _list_2 = self.localFS:Find('autorun/server/*.lua')
        for _index_0 = 1, #_list_2 do
          local fil = _list_2[_index_0]
          self:RunFile('autorun/server/' .. fil)
        end
      end
      if CLIENT then
        local _list_2 = self.localFS:Find('autorun/client/*.lua')
        for _index_0 = 1, #_list_2 do
          local fil = _list_2[_index_0]
          self:RunFile('autorun/client/' .. fil)
        end
      end
    end,
    LoadEntities = function(self)
      local pendingMeta = { }
      local files, dirs = self.localFS:Find('entities/*.lua')
      for _index_0 = 1, #files do
        local _file = files[_index_0]
        _G.ENT = { }
        ENT.Folder = 'entities'
        self:RunFile('entities/' .. _file)
        local ename = string.sub(_file, 1, -5)
        scripted_ents.Register(ENT, ename)
        baseclass.Set(ename, ENT)
        table.insert(pendingMeta, ename)
        _G.ENT = nil
      end
      for _index_0 = 1, #dirs do
        local _dir = dirs[_index_0]
        local hit = self.localFS:Exists('entities/' .. _dir .. '/shared.lua') or self.localFS:Exists('entities/' .. _dir .. '/init.lua') and SERVER or self.localFS:Exists('entities/' .. _dir .. '/cl_init.lua') and CLIENT
        if hit then
          _G.ENT = { }
          ENT.Folder = 'entities/' .. _dir
          if self.localFS:Exists('entities/' .. _dir .. '/shared.lua') then
            self:RunFile('entities/' .. _dir .. '/shared.lua')
          end
          if self.localFS:Exists('entities/' .. _dir .. '/init.lua') and SERVER then
            self:RunFile('entities/' .. _dir .. '/init.lua')
          end
          if self.localFS:Exists('entities/' .. _dir .. '/cl_init.lua') and CLIENT then
            self:RunFile('entities/' .. _dir .. '/cl_init.lua')
          end
          scripted_ents.Register(ENT, _dir)
          baseclass.Set(_dir, ENT)
          table.insert(pendingMeta, _dir)
          _G.ENT = nil
        end
      end
      local _list_0 = pendingMeta
      for _index_0 = 1, #_list_0 do
        local _meta = _list_0[_index_0]
        VLL2.RecursiveMergeBase(meta)
      end
    end,
    LoadEffects = function(self)
      local files, dirs = self.localFS:Find('effects/*.lua')
      for _index_0 = 1, #files do
        local _file = files[_index_0]
        _G.EFFECT = { }
        EFFECT.Folder = 'effects'
        self:RunFile('effects/' .. _file)
        local ename = string.sub(_file, 1, -5)
        effects.Register(EFFECT, ename)
        _G.EFFECT = nil
      end
      for _index_0 = 1, #dirs do
        local _dir = dirs[_index_0]
        if self.localFS:Exists('effects/' .. _dir .. '/init.lua') then
          _G.EFFECT = { }
          EFFECT.Folder = 'effects/' .. _dir
          self:RunFile('effects/' .. _dir .. '/init.lua')
          effects.Register(EFFECT, _dir)
          _G.EFFECT = nil
        end
      end
    end,
    LoadToolguns = function(self)
      local files, dirs = self.localFS:Find('weapons/gmod_tool/stools/*.lua')
      if #files == 0 then
        return 
      end
      if not weapons.Get('gmod_tool') then
        return 
      end
      _G.SWEP = { }
      SWEP.Folder = 'weapons/gmod_tool'
      SWEP.Primary = { }
      SWEP.Secondary = { }
      if SERVER then
        self:RunFile('weapons/gmod_tool/init.lua')
      end
      if CLIENT then
        self:RunFile('weapons/gmod_tool/cl_init.lua')
      end
      weapons.Register(SWEP, 'gmod_tool')
      baseclass.Set('gmod_tool', SWEP)
      _G.SWEP = nil
    end,
    LoadWeapons = function(self)
      local pendingMeta = { }
      local files, dirs = self.localFS:Find('weapons/*.lua')
      for _index_0 = 1, #files do
        local _file = files[_index_0]
        _G.SWEP = { }
        SWEP.Folder = 'weapons'
        SWEP.Primary = { }
        SWEP.Secondary = { }
        self:RunFile('weapons/' .. _file)
        local ename = string.sub(_file, 1, -5)
        weapons.Register(SWEP, ename)
        baseclass.Set(ename, SWEP)
        table.insert(pendingMeta, ename)
        _G.SWEP = nil
      end
      for _index_0 = 1, #dirs do
        local _dir = dirs[_index_0]
        local hit = self.localFS:Exists('weapons/' .. _dir .. '/shared.lua') or self.localFS:Exists('weapons/' .. _dir .. '/init.lua') and SERVER or self.localFS:Exists('weapons/' .. _dir .. '/cl_init.lua') and CLIENT
        if hit then
          _G.SWEP = { }
          SWEP.Folder = 'weapons/' .. _dir
          SWEP.Primary = { }
          SWEP.Secondary = { }
          if self.localFS:Exists('weapons/' .. _dir .. '/shared.lua') then
            self:RunFile('weapons/' .. _dir .. '/shared.lua')
          end
          if self.localFS:Exists('weapons/' .. _dir .. '/init.lua') and SERVER then
            self:RunFile('weapons/' .. _dir .. '/init.lua')
          end
          if self.localFS:Exists('weapons/' .. _dir .. '/cl_init.lua') and CLIENT then
            self:RunFile('weapons/' .. _dir .. '/cl_init.lua')
          end
          weapons.Register(SWEP, _dir)
          baseclass.Set(_dir, SWEP)
          table.insert(pendingMeta, _dir)
          _G.SWEP = nil
        end
      end
      local _list_0 = pendingMeta
      for _index_0 = 1, #_list_0 do
        local _meta = _list_0[_index_0]
        VLL2.RecursiveMergeBase(meta)
      end
    end,
    __TFALoader = function(self, fpath)
      local files = self.localFS:Find(fpath .. '/*')
      for _index_0 = 1, #files do
        local _file = files[_index_0]
        if not _file:StartWith('cl_') and not _file:StartWith('sv_') then
          self:RunFile(fpath .. '/' .. _file)
        end
      end
      local _list_0 = files
      for _index_0 = 1, #_list_0 do
        local _file = _list_0[_index_0]
        if _file:StartWith('cl_') and CLIENT or _file:StartWith('sv_') and SERVER then
          self:RunFile(fpath .. '/' .. _file)
        end
      end
    end,
    LoadTFA = function(self)
      self:__TFALoader('tfa/modules')
      self:__TFALoader('tfa/external')
      local files = self.localFS:Find('tfa/att/*')
      if #files > 0 then
        return TFAUpdateAttachments()
      end
    end,
    Exists = function(self, fpath)
      return self.localFS:Exists(fpath) or self.globalFS and self.globalFS:Exists(fpath)
    end,
    NewEnv = function(self, fpath)
      assert(type(fpath) ~= 'nil', 'No fpath were provided!')
      local env
      do
        local _tbl_0 = { }
        for k, v in pairs(self.env) do
          _tbl_0[k] = v
        end
        env = _tbl_0
      end
      env.VLL2_FILEDEF = type(fpath) == 'string' and VLL2.FileDef(fpath, self) or fpath
      setmetatable(env, {
        __index = _G,
        __newindex = function(self, key, value)
          _G[key] = value
        end
      })
      return env
    end,
    CompileString = function(self, strIn, identifier, fdef)
      if identifier == nil then
        identifier = 'CompileString'
      end
      assert(fdef, 'File definition from where CompileString was called must be present')
      local fcall, ferrMsg = CompileString(strIn, identifier, false)
      if type(fcall) == 'string' or ferrMsg then
        local emsg = type(fcall) == 'string' and fcall or ferrMsg
        local callable
        callable = function()
          VLL2.MessageVM('Compilation failed for "CompileString" inside ' .. self.vmName .. ':', emsg)
          string.gsub(emsg, ':[0-9]+:', function(w)
            local fline = string.sub(w, 2, #w - 1)
            local i = 0
            for line in string.gmatch(strIn, '\r?\n') do
              i = i + 1
              if i == fline then
                VLL2.MessageVM(line)
                break
              end
            end
          end)
          return error(emsg)
        end
        callable()
        return callable, false, emsg
      end
      setfenv(fcall, self:NewEnv(fdef))
      return fcall, true
    end,
    __CompileFileFallback = function(self, fpath)
      local cstatus, fcall = pcall(CompileFile, fpath)
      if not cstatus then
        local callable
        callable = function()
          return VLL2.MessageVM('Compilation failed for ' .. fpath .. ' inside ' .. self.vmName)
        end
        callable()
        return callable, false, fcall
      end
      if not fcall then
        local callable
        callable = function()
          VLL2.MessageVM('File is missing: ' .. fpath .. ' inside ' .. self.vmName)
          return nil
        end
        callable()
        return callable, true
      end
      setfenv(fcall, self:NewEnv(fpath))
      return fcall, true
    end,
    Msg = function(self, ...)
      return VLL2.MessageVM(self.vmName .. ': ', ...)
    end,
    RunFile = function(self, fpath)
      local fget, fstatus, ferror = self:CompileFile(fpath)
      if not fstatus then
        VLL2.MessageVM(ferror)
      end
      self:Msg('Running file ' .. fpath)
      return fget()
    end,
    CompileFile = function(self, fpath2)
      local fpath = VLL2.FileSystem.Canonize(fpath2)
      if not fpath then
        return self:__CompileFileFallback(fpath2)
      end
      local fread
      if self.localFS:Exists(fpath) then
        fread = self.localFS:Read(fpath)
      elseif self.globalFS and self.globalFS:Exists(fpath) then
        fread = self.globalFS:Read(fpath)
      else
        return self:__CompileFileFallback(fpath)
      end
      if #fread < 10 then
        VLL2.MessageVM(self.vmName, ' ', self.localFS, ' ', self.globalFS)
        for key, value in pairs(self.env) do
          VLL2.MessageVM(key, ' ', value)
        end
        VLL2.MessageVM('-----------------')
        VLL2.MessageVM(fread)
        VLL2.MessageVM('-----------------')
        error('wtf')
      end
      local fcall = CompileString(fread, '[VLL2:VM:' .. self.vmName .. ':' .. fpath .. ']', false)
      if type(fcall) == 'string' then
        local callable
        callable = function()
          VLL2.MessageVM('Compilation failed for ' .. fpath .. ' inside ' .. self.vmName)
          return string.gsub(fcall, ':[0-9]+:', function(w)
            local fline = string.sub(w, 2, #w - 1)
            local i = 0
            for line in string.gmatch(fread, '\r?\n') do
              i = i + 1
              if i == fline then
                VLL2.MessageVM(line)
                break
              end
            end
          end)
        end
        callable()
        return callable, false, fcall
      end
      setfenv(fcall, self:NewEnv(fpath2))
      return fcall, true
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, vmName, localFS, globalFS)
      self.vmName = vmName
      self.localFS = localFS
      self.globalFS = globalFS
      do
        local _tbl_0 = { }
        for k, v in pairs(VLL2.ENV_TEMPLATE) do
          _tbl_0[k] = v
        end
        self.env = _tbl_0
      end
      self.env.VLL2_VM = self
      self.env._G = _G
    end,
    __base = _base_0,
    __name = "VM"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  VLL2.VM = _class_0
  return _class_0
end
end)
if not ___status then
	VLL2.Message('STARTUP FAILURE AT VM: ', ___err)
end

if CLIENT then
	___status, ___err = pcall(function()
local VLL2, table, hook, surface, draw, ScrW, ScrH, TEXT_ALIGN_CENTER
do
  local _obj_0 = _G
  VLL2, table, hook, surface, draw, ScrW, ScrH, TEXT_ALIGN_CENTER = _obj_0.VLL2, _obj_0.table, _obj_0.hook, _obj_0.surface, _obj_0.draw, _obj_0.ScrW, _obj_0.ScrH, _obj_0.TEXT_ALIGN_CENTER
end
local bundlelist = {
  VLL2.URLBundle,
  VLL2.WSBundle,
  VLL2.GMABundle,
  VLL2.WSCollection
}
surface.CreateFont('VLL2.Message', {
  font = 'Roboto',
  size = ScreenScale(14)
})
local WARN_COLOR = Color(188, 15, 20)
return hook.Add('HUDPaint', 'VLL2.HUDMessages', function()
  local messages
  for _index_0 = 1, #bundlelist do
    local bundle = bundlelist[_index_0]
    local msgs = bundle:GetMessage()
    if msgs then
      messages = messages or { }
      if type(msgs) == 'string' then
        table.insert(messages, msgs)
      else
        for _index_1 = 1, #msgs do
          local _i = msgs[_index_1]
          table.insert(messages, _i)
        end
      end
    end
  end
  if not messages then
    return 
  end
  local x, y = ScrW() / 2, ScrH() * 0.11
  for _index_0 = 1, #messages do
    local message = messages[_index_0]
    draw.DrawText(message, 'VLL2.Message', x, y, WARN_COLOR, TEXT_ALIGN_CENTER)
    local w, h = surface.GetTextSize(message)
    y = y + (h * 1.1)
  end
end)
end)
	if not ___status then
		VLL2.Message('STARTUP FAILURE AT HUD: ', ___err)
	end
end
___status, ___err = pcall(function()
local concommand, table, string, VLL2
do
  local _obj_0 = _G
  concommand, table, string, VLL2 = _obj_0.concommand, _obj_0.table, _obj_0.string, _obj_0.VLL2
end
local sv_allowcslua = GetConVar('sv_allowcslua')
local disallow
disallow = function(self)
  return SERVER and not game.SinglePlayer() and IsValid(self) and not self:IsSuperAdmin() or CLIENT and not self:IsSuperAdmin() and not sv_allowcslua:GetBool()
end
local disallow2
disallow2 = function(self)
  return SERVER and not game.SinglePlayer() and IsValid(self) and not self:IsSuperAdmin()
end
if SERVER then
  util.AddNetworkString('vll2_cmd_load_server')
end
local autocomplete = { }
timer.Simple(0, function()
  return http.Fetch('https://dbotthepony.ru/vll/plist.php', function(body, size, headers, code)
    if body == nil then
      body = ''
    end
    if size == nil then
      size = string.len(body)
    end
    if headers == nil then
      headers = { }
    end
    if code == nil then
      code = 400
    end
    if code ~= 200 then
      return 
    end
    do
      local _accum_0 = { }
      local _len_0 = 1
      local _list_0 = string.Explode('\n', body)
      for _index_0 = 1, #_list_0 do
        local _file = _list_0[_index_0]
        if _file:Trim() ~= '' then
          _accum_0[_len_0] = _file:Trim():lower()
          _len_0 = _len_0 + 1
        end
      end
      autocomplete = _accum_0
    end
    return table.sort(autocomplete)
  end)
end)
local vll2_load
vll2_load = function(ply, cmd, args)
  if disallow(ply) then
    return VLL2.MessagePlayer(ply, 'Not a super admin!')
  end
  local bundle = args[1]
  if not bundle then
    return VLL2.MessagePlayer(ply, 'No bundle were specified.')
  end
  if not VLL2.AbstractBundle:Checkup(bundle:lower()) then
    return VLL2.MessagePlayer(ply, 'Bundle is already loading!')
  end
  local fbundle = VLL2.URLBundle(bundle:lower())
  fbundle:Load()
  fbundle:Replicate()
  return VLL2.MessagePlayer(ply, 'Loading URL Bundle: ' .. bundle)
end
local vll2_mkautocomplete
vll2_mkautocomplete = function(commandToReg)
  return function(cmd, args)
    if not args then
      return 
    end
    args = args:Trim():lower()
    if args == '' then
      local _accum_0 = { }
      local _len_0 = 1
      for _index_0 = 1, #autocomplete do
        local _file = autocomplete[_index_0]
        _accum_0[_len_0] = commandToReg .. ' ' .. _file
        _len_0 = _len_0 + 1
      end
      return _accum_0
    end
    local result
    do
      local _accum_0 = { }
      local _len_0 = 1
      for _index_0 = 1, #autocomplete do
        local _file = autocomplete[_index_0]
        if _file:StartWith(args) then
          _accum_0[_len_0] = commandToReg .. ' ' .. _file
          _len_0 = _len_0 + 1
        end
      end
      result = _accum_0
    end
    return result
  end
end
local vll2_workshop
vll2_workshop = function(ply, cmd, args)
  if disallow(ply) then
    return VLL2.MessagePlayer(ply, 'Not a super admin!')
  end
  local bundle = args[1]
  if not bundle then
    return VLL2.MessagePlayer(ply, 'No workshop ID were specified.')
  end
  if not VLL2.AbstractBundle:Checkup(bundle:lower()) then
    return VLL2.MessagePlayer(ply, 'Bundle is already loading!')
  end
  if not tonumber(bundle) then
    return VLL2.MessagePlayer(ply, 'Invalid ID provided. it must be an integer')
  end
  local fbundle = VLL2.WSBundle(tostring(math.floor(tonumber(bundle))):lower())
  fbundle:Load()
  fbundle:Replicate()
  return VLL2.MessagePlayer(ply, 'Loading Workshop Bundle: ' .. bundle)
end
local vll2_wscollection
vll2_wscollection = function(ply, cmd, args)
  if disallow(ply) then
    return VLL2.MessagePlayer(ply, 'Not a super admin!')
  end
  local bundle = args[1]
  if not bundle then
    return VLL2.MessagePlayer(ply, 'No workshop ID of collection were specified.')
  end
  if not VLL2.AbstractBundle:Checkup(bundle:lower()) then
    return VLL2.MessagePlayer(ply, 'Bundle is already loading!')
  end
  if not tonumber(bundle) then
    return VLL2.MessagePlayer(ply, 'Invalid ID provided. it must be an integer')
  end
  local fbundle = VLL2.WSCollection(tostring(math.floor(tonumber(bundle))):lower())
  fbundle:Load()
  fbundle:Replicate()
  return VLL2.MessagePlayer(ply, 'Loading Workshop collection Bundle: ' .. bundle .. '. Hold on tigh!')
end
local vll2_wscollection_content
vll2_wscollection_content = function(ply, cmd, args)
  if disallow2(ply) then
    return VLL2.MessagePlayer(ply, 'Not a super admin!')
  end
  local bundle = args[1]
  if not bundle then
    return VLL2.MessagePlayer(ply, 'No workshop ID of collection were specified.')
  end
  if not VLL2.AbstractBundle:Checkup(bundle:lower()) then
    return VLL2.MessagePlayer(ply, 'Bundle is already loading!')
  end
  if not tonumber(bundle) then
    return VLL2.MessagePlayer(ply, 'Invalid ID provided. it must be an integer')
  end
  local fbundle = VLL2.WSCollection(tostring(math.floor(tonumber(bundle))):lower())
  fbundle:DoNotLoadLua()
  fbundle:Load()
  fbundle:Replicate()
  return VLL2.MessagePlayer(ply, 'Loading Workshop collection Bundle: ' .. bundle .. ' without mounting Lua. Hold on tigh!')
end
local vll2_workshop_silent
vll2_workshop_silent = function(ply, cmd, args)
  if disallow(ply) then
    return VLL2.MessagePlayer(ply, 'Not a super admin!')
  end
  local bundle = args[1]
  if not bundle then
    return VLL2.MessagePlayer(ply, 'No workshop ID were specified.')
  end
  if not VLL2.AbstractBundle:Checkup(bundle:lower()) then
    return VLL2.MessagePlayer(ply, 'Bundle is already loading!')
  end
  if not tonumber(bundle) then
    return VLL2.MessagePlayer(ply, 'Invalid ID provided. it must be an integer')
  end
  local fbundle = VLL2.WSBundle(tostring(math.floor(tonumber(bundle))):lower())
  fbundle:Load()
  fbundle:DoNotReplicate()
  return VLL2.MessagePlayer(ply, 'Loading Workshop Bundle: ' .. bundle)
end
local vll2_workshop_content
vll2_workshop_content = function(ply, cmd, args)
  if disallow2(ply) then
    return VLL2.MessagePlayer(ply, 'Not a super admin!')
  end
  local bundle = args[1]
  if not bundle then
    return VLL2.MessagePlayer(ply, 'No workshop ID were specified.')
  end
  if not VLL2.AbstractBundle:Checkup(bundle:lower()) then
    return VLL2.MessagePlayer(ply, 'Bundle is already loading!')
  end
  if not tonumber(bundle) then
    return VLL2.MessagePlayer(ply, 'Invalid ID provided. it must be an integer')
  end
  local fbundle = VLL2.WSBundle(tostring(math.floor(tonumber(bundle))):lower())
  fbundle:DoNotLoadLua()
  fbundle:Load()
  fbundle:Replicate()
  return VLL2.MessagePlayer(ply, 'Loading Workshop Bundle: ' .. bundle .. ' without mounting Lua')
end
local vll2_workshop_content_silent
vll2_workshop_content_silent = function(ply, cmd, args)
  if disallow2(ply) then
    return VLL2.MessagePlayer(ply, 'Not a super admin!')
  end
  local bundle = args[1]
  if not bundle then
    return VLL2.MessagePlayer(ply, 'No workshop ID were specified.')
  end
  if not VLL2.AbstractBundle:Checkup(bundle:lower()) then
    return VLL2.MessagePlayer(ply, 'Bundle is already loading!')
  end
  if not tonumber(bundle) then
    return VLL2.MessagePlayer(ply, 'Invalid ID provided. it must be an integer')
  end
  local fbundle = VLL2.WSBundle(tostring(math.floor(tonumber(bundle))):lower())
  fbundle:DoNotLoadLua()
  fbundle:Load()
  fbundle:DoNotReplicate()
  return VLL2.MessagePlayer(ply, 'Loading Workshop Bundle: ' .. bundle .. ' without mounting Lua')
end
local vll2_load_silent
vll2_load_silent = function(ply, cmd, args)
  if disallow(ply) then
    return VLL2.MessagePlayer(ply, 'Not a super admin!')
  end
  local bundle = args[1]
  if not bundle then
    return VLL2.MessagePlayer(ply, 'No bundle were specified.')
  end
  if not VLL2.AbstractBundle:Checkup(bundle:lower()) then
    return VLL2.MessagePlayer(ply, 'Bundle is already loading!')
  end
  local fbundle = VLL2.URLBundle(bundle:lower())
  fbundle:Load()
  fbundle:DoNotReplicate()
  return VLL2.MessagePlayer(ply, 'Loading URL Bundle: ' .. bundle)
end
local vll2_reload
vll2_reload = function(ply, cmd, args)
  if disallow(ply) then
    return VLL2.MessagePlayer(ply, 'Not a super admin!')
  end
  VLL2.MessagePlayer(ply, 'Reloading VLL2, this can take some time...')
  _G.VLL2_GOING_TO_RELOAD = true
  return http.Fetch("https://dbotthepony.ru/vll/vll2.lua", function(b)
    return _G.RunString(b, "VLL2")
  end)
end
local vll2_reload_full
vll2_reload_full = function(ply, cmd, args)
  if disallow(ply) then
    return VLL2.MessagePlayer(ply, 'Not a super admin!')
  end
  VLL2.MessagePlayer(ply, 'Flly Reloading VLL2, this can take some time...')
  _G.VLL2_GOING_TO_RELOAD = true
  _G.VLL2_FULL_RELOAD = true
  return http.Fetch("https://dbotthepony.ru/vll/vll2.lua", function(b)
    return _G.RunString(b, "VLL2")
  end)
end
local vll2_clear_lua_cache
vll2_clear_lua_cache = function(ply, cmd, args)
  if disallow(ply) then
    return VLL2.MessagePlayer(ply, 'Not a super admin!')
  end
  sql.Query('DELETE FROM vll2_lua_cache')
  return VLL2.MessagePlayer(ply, 'Lua cache has been cleared.')
end
return timer.Simple(0, function()
  if not game.SinglePlayer() or CLIENT then
    concommand.Add('vll2_load', vll2_load, vll2_mkautocomplete('vll2_load'))
    concommand.Add('vll2_workshop', vll2_workshop)
    concommand.Add('vll2_wscollection', vll2_wscollection)
    concommand.Add('vll2_wscollection_content', vll2_wscollection_content)
    concommand.Add('vll2_workshop_silent', vll2_workshop_silent)
    concommand.Add('vll2_workshop_content_silent', vll2_workshop_content_silent)
    concommand.Add('vll2_reload', vll2_reload)
    concommand.Add('vll2_reload_full', vll2_reload_full)
    concommand.Add('vll2_clear_lua_cache', vll2_clear_lua_cache)
  end
  if SERVER then
    net.Receive('vll2_cmd_load_server', function(_, ply)
      return vll2_load(ply, nil, string.Explode(' ', net.ReadString():Trim()))
    end)
    concommand.Add('vll2_load_server', vll2_load, vll2_mkautocomplete('vll2_load_server'))
    concommand.Add('vll2_load_silent', vll2_load_silent, vll2_mkautocomplete('vll2_load_silent'))
    concommand.Add('vll2_workshop_server', vll2_workshop)
    concommand.Add('vll2_wscollection_server', vll2_wscollection)
    concommand.Add('vll2_wscollection_content_server', vll2_wscollection_content)
    concommand.Add('vll2_workshop_content_server', vll2_workshop_content)
    concommand.Add('vll2_workshop_silent_server', vll2_workshop_silent)
    concommand.Add('vll2_workshop_content_silent_server', vll2_workshop_content_silent)
    concommand.Add('vll2_reload_server', vll2_reload)
    concommand.Add('vll2_reload_full_server', vll2_reload_full)
    return concommand.Add('vll2_clear_lua_cache_server', vll2_clear_lua_cache)
  else
    local vll2_load_server
    vll2_load_server = function(ply, cmd, args)
      net.Start('vll2_cmd_load_server')
      net.WriteString(args[1])
      return net.SendToServer()
    end
    return timer.Simple(0, function()
      return timer.Simple(0, function()
        if not game.SinglePlayer() then
          return concommand.Add('vll2_load_server', vll2_load_server, vll2_mkautocomplete('vll2_load_server'))
        end
      end)
    end)
  end
end)
end)
if not ___status then
	VLL2.Message('STARTUP FAILURE AT COMMANDS: ', ___err)
end

VLL2.Message('Startup finished')
hook.Run('VLL2.Loaded')

