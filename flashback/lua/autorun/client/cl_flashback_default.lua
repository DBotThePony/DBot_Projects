
--[[
Copyright (C) 2016 DBot

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

local self = DFlashback

local VALID_PROPS = {}
local VALID_PROPS_SOUNDS = {}

local function CheckEntity(ent)
	local cond = ent:GetClass() == 'class C_PhysPropClientside' and
		ent:GetPhysicsObject():IsValid() and
		ent:GetModel()
	
	return cond
end

local function GetPropID(ent)
	return ent:GetNWInt('FlashBackNetworkID')
end

timer.Create('DFlashback.Default.UpdatePropList', 1, 0, function()
	if not self.IsRecording then return end
	
	VALID_PROPS = {}
	
	for k, v in ipairs(ents.GetAll()) do
		if CheckEntity(v) then
			VALID_PROPS[GetPropID(v)] = v
		end
		
		VALID_PROPS_SOUNDS[GetPropID(v)] = v
	end
end)

local StasisFuncs = {
	{'GetModel', 'SetModel'},
	{'GetPos', 'SetPos'},
	{'GetAngles', 'SetAngles'},
	{'GetSkin', 'SetSkin'},
	{'GetMaterial', 'SetMaterial'},
}

local DeltaFuncs = {
	{'GetModel', 'SetModel'},
	{'GetPos', 'SetPos'},
	{'GetAngles', 'SetAngles'},
	{'GetSkin', 'SetSkin'},
	{'GetMaterial', 'SetMaterial'},
	{'GetColor', 'SetColor'},
}

local Default = {
	ents = {
		record = function(data, myKey)
			data.FrameProps = {}
			
			for uid, v in pairs(VALID_PROPS) do
				if not v:IsValid() then continue end
				
				data.FrameProps[uid] = v
				
				for i, names in ipairs(DeltaFuncs) do
					local status, errOrResult = pcall(v[names[1]], v)
					
					if status then
						self.WriteDelta(myKey, uid .. ' ' .. i, errOrResult)
					else
						print(errOrResult)
					end
				end
				
				local phys = v:GetPhysicsObject()

				self.WriteDelta(myKey, uid .. 'motion', phys:IsMotionEnabled())
				self.WriteDelta(myKey, uid .. 'mass', phys:GetMass())
			end
		end,
		
		replay = function(data, myKey)
			if not data.FrameProps then return end
			
			for uid, v in pairs(data.FrameProps) do
				if not v:IsValid() then
					if IsValid(VALID_PROPS[uid]) then
						v = VALID_PROPS[uid]
					else
						continue
					end
				end
				
				if v == NULL then continue end -- ???
				
				if v.FlashbackTimeSpawned == self.CurTime() then
					SafeRemoveEntity(v)
					continue
				end
				
				for i, names in ipairs(DeltaFuncs) do
					local get = self.FindDelta(myKey, uid .. ' ' .. i)
					
					if not get then continue end
					local status, err = pcall(v[names[2]], v, get)
					
					if not status then
						print(err)
					end
				end
				
				local phys = v:GetPhysicsObject()
				
				if not IsValid(phys) then
					v:Remove()
					continue
				end
				
				phys:EnableMotion(self.FindDelta(myKey, uid .. 'motion', phys:IsMotionEnabled()))
				phys:SetMass(self.FindDelta(myKey, uid .. 'mass', phys:GetMass()))
			end
		end,
		
		ends_replay = function()
			for k, ent in pairs(VALID_PROPS) do
				if ent:IsValid() then
					local phys = ent:GetPhysicsObject()
					phys:Wake()
				end
			end
		end,
	},
	
	ents_restore = {
		replay = function(data, myKey)
			if not data.ToRestore then return end
			
			for i, entry in ipairs(data.ToRestore) do
				if entry.tab.FlashbackTimeSpawned == self.CurTime() then continue end
				
				local ent = ClientsideModel(entry.model, entry.group)
				
				for id, val in ipairs(StasisFuncs) do
					if #entry.stasis[id] ~= 0 then
						local status, err = pcall(ent[val[2]], ent, unpack(entry.stasis[id]))
						
						if not status then
							print(err)
							print(debug.traceback())
						end
					end
				end
				
				local newTab = ent:GetTable()
				
				for key, value in pairs(entry.tab) do
					newTab[key] = value
				end
				
				timer.Simple(0, function()
					local newTab = ent:GetTable()
					
					for key, value in pairs(entry.tab) do
						newTab[key] = value
					end
				end)
				
				if ent.Flashback_PropID then
					VALID_PROPS[ent.Flashback_PropID] = ent
				end
			end
		end,
	},
	
	sounds = {
		replay = function(data, key)
			if not data.sounds then return end
			
			for uid, sndData in pairs(data.sounds) do
				local ent = VALID_PROPS_SOUNDS[uid]
				
				if not IsValid(ent) then return end
				
				for i, vals in ipairs(sndData) do
					EmitSound(
						vals.SoundName or vals.OriginalSoundName,
						vals.Pos or ent:GetPos(),
						ent:EntIndex(),
						vals.Channel,
						vals.Volume or 1,
						vals.SoundLevel or 75,
						SND_STOP_LOOPING,
						vals.Pitch or 100
					)
				end
			end
		end
	}
}

local function OnEntityCreated(ent)
	if not self.IsRecording then return end
	
	local time = self.GetCurrentFrame().CurTime
	local data = self.GetCurrentData('DFlashback.DefaultClient.ents')
	data.FrameProps = data.FrameProps or {}
	
	timer.Simple(0, function()
		if not IsValid(ent) then return end
		if not CheckEntity(ent) then return end
		
		ent.Flashback_PropID = ent.Flashback_PropID or math.random(1, 10000)
		ent.FlashbackTimeSpawned = time
		VALID_PROPS[ent.Flashback_PropID] = ent
		data.FrameProps[ent.Flashback_PropID] = ent
	end)
end

local function EntityRemoved(ent)
	if not self.IsRecording then return end
	if not CheckEntity(ent) then return end
	if true then return end -- Really, broken for now
	
	local data = self.GetCurrentData('DFlashback.DefaultClient.ents_restore')
	data.ToRestore = data.ToRestore or {}
	local entry = {}
	table.insert(data.ToRestore, entry)
	
	entry.model = ent:GetModel()
	entry.group = ent:GetRenderGroup()
	entry.tab = ent:GetTable() or {}
	
	entry.stasis = {}
	
	for i, val in ipairs(StasisFuncs) do
		entry.stasis[i] = {ent[val[1]](ent)}
	end
end

local function EntityEmitSound(soundData)
	if not self.IsRecording then return end
	local ent = soundData.Entity
	
	if not IsValid(ent) then return end
	
	VALID_PROPS_SOUNDS[GetPropID(ent)] = ent
	local uid = GetPropID(ent)
	
	local data = self.GetCurrentData('DFlashback.DefaultClient.sounds')
	
	data.sounds = data.sounds or {}
	data.sounds[uid] = data.sounds[uid] or {}
	
	table.insert(data.sounds[uid], table.Copy(soundData))
end

hook.Add('OnEntityCreated', 'DFlashback.DefaultClient.PropDelete', OnEntityCreated)
hook.Add('EntityRemoved', 'DFlashback.DefaultClient.RestoreEntity', EntityRemoved)
hook.Add('EntityEmitSound', 'DFlashback.DefaultClient.Sounds', EntityEmitSound)

for k, v in pairs(Default) do
	hook.Add('FlashbackRecordFrame', 'DFlashback.DefaultClient.' .. k, v.record)
	hook.Add('FlashbackRestoreFrame', 'DFlashback.DefaultClient.' .. k, v.replay)
	hook.Add('FlashbackStartsRestore', 'DFlashback.DefaultClient.' .. k, v.starts_replay)
	hook.Add('FlashbackEndsRestore', 'DFlashback.DefaultClient.' .. k, v.ends_replay)
end
