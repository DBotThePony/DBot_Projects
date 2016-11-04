
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
	local cond = ent:GetSolid() == SOLID_NONE or
		ent:CreatedByMap() or
		ent:IsNPC() or
		ent:IsWeapon() or
		ent:IsConstraint() or
		ent:IsPlayer()
	
	return not cond
end

local function CheckEntitySound(ent)
	local cond = ent:GetSolid() == SOLID_NONE or
		ent:IsConstraint()
	
	return not cond
end

timer.Create('DFlashback.Default.UpdatePropList', 1, 0, function()
	if not self.IsRecording then return end
	
	VALID_PROPS = {}
	
	for k, v in ipairs(ents.GetAll()) do
		if CheckEntity(v) then
			v.Flashback_PropID = v.Flashback_PropID or math.random(1, 10000)
			VALID_PROPS[v.Flashback_PropID] = v
		end
		
		if CheckEntitySound(v) then
			v.Flashback_PropID = v.Flashback_PropID or math.random(1, 10000)
			VALID_PROPS_SOUNDS[v.Flashback_PropID] = v
		end
	end
end)

local StasisFuncs = {
	{'GetModel', 'SetModel'},
	{'GetSolid', 'SetSolid'},
	{'GetPos', 'SetPos'},
	{'GetAngles', 'SetAngles'},
	{'GetSkin', 'SetSkin'},
}

local Default = {
	player = {
		record = function(data, myKey)
			for k, ply in ipairs(player.GetAll()) do
				local uid = ply:UserID()
				
				self.WriteDelta(myKey, uid .. 'mvtype', ply:GetMoveType())
				self.WriteDelta(myKey, uid .. 'pos', ply:GetPos())
				self.WriteDelta(myKey, uid .. 'ang', ply:EyeAngles())
				self.WriteDelta(myKey, uid .. 'health', ply:Health())
				self.WriteDelta(myKey, uid .. 'maxhealth', ply:GetMaxHealth())
				self.WriteDelta(myKey, uid .. 'velocity', ply:GetVelocity())
				
				local wep = ply:GetActiveWeapon()
				
				if wep:IsValid() then
					self.WriteDelta(myKey, uid .. 'weaponclass', wep:GetClass())
				end
			end
		end,
		
		replay = function(data, myKey)
			for k, ply in ipairs(player.GetAll()) do
				local uid = ply:UserID()
				
				ply.FlashBackLastMoveType = self.FindDelta(myKey, uid .. 'mvtype', ply.FlashBackLastMoveType or MOVETYPE_WALK)
				ply:SetPos(self.FindDelta(myKey, uid .. 'pos', ply:GetPos()))
				ply:SetEyeAngles(self.FindDelta(myKey, uid .. 'ang', ply:EyeAngles()))
				ply:SetHealth(self.FindDelta(myKey, uid .. 'health', ply:Health()))
				ply:SetMaxHealth(self.FindDelta(myKey, uid .. 'maxhealth', ply:GetMaxHealth()))
				
				local currVel = ply:GetVelocity()
				local oldVel = self.FindDelta(myKey, uid .. 'velocity', currVel)
				
				ply:SetVelocity(oldVel - currVel)
				
				local get = self.FindDelta(myKey, uid .. 'weaponclass')
				
				if get then
					ply:SelectWeapon(get)
				end
			end
		end,
		
		starts_replay = function()
			for k, ply in ipairs(player.GetAll()) do
				ply:SetMoveType(MOVETYPE_NONE)
				ply.FlashBackLastMoveType = nil
			end
		end,
		
		ends_replay = function()
			for k, ply in ipairs(player.GetAll()) do
				ply:SetMoveType(ply.FlashBackLastMoveType or MOVETYPE_WALK)
				ply.FlashBackLastMoveType = nil
			end
		end,
	},
	
	ents = {
		record = function(data, myKey)
			data.FrameProps = {}
			
			for uid, v in pairs(VALID_PROPS) do
				if not v:IsValid() then continue end
				
				data.FrameProps[uid] = v
				
				self.WriteDelta(myKey, uid .. 'pos', v:GetPos())
				self.WriteDelta(myKey, uid .. 'ang', v:GetAngles())
				self.WriteDelta(myKey, uid .. 'health', v:Health())
				self.WriteDelta(myKey, uid .. 'mhealth', v:GetMaxHealth())
				self.WriteDelta(myKey, uid .. 'velocity', v:GetVelocity())
				
				self.WriteDelta(myKey, uid .. 'model', v:GetModel())
				self.WriteDelta(myKey, uid .. 'skin', v:GetSkin())
				
				local phys = v:GetPhysicsObject()
				
				if phys:IsValid() then
					self.WriteDelta(myKey, uid .. 'motion', phys:IsMotionEnabled())
				end
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
				
				v:SetPos(self.FindDelta(myKey, uid .. 'pos', v:GetPos()))
				v:SetAngles(self.FindDelta(myKey, uid .. 'ang', v:GetAngles()))
				v:SetHealth(self.FindDelta(myKey, uid .. 'health', v:Health()))
				v:SetMaxHealth(self.FindDelta(myKey, uid .. 'mhealth', v:GetMaxHealth()))
				v:SetVelocity(self.FindDelta(myKey, uid .. 'velocity', v:GetVelocity()))
				
				v:SetModel(self.FindDelta(myKey, uid .. 'model', v:GetModel()))
				v:SetSkin(self.FindDelta(myKey, uid .. 'skin', v:GetSkin()))
				
				local phys = v:GetPhysicsObject()
				
				if phys:IsValid() then
					phys:EnableMotion(self.WriteDelta(myKey, uid .. 'motion', phys:IsMotionEnabled()))
				end
			end
		end,
	},
	
	ents_restore = {
		replay = function(data, myKey)
			if not data.ToRestore then return end
			
			for i, entry in ipairs(data.ToRestore) do
				if entry.tab.FlashbackTimeSpawned == self.CurTime() then continue end
				
				local ent = ents.Create(entry.class)
				
				for id, val in ipairs(StasisFuncs) do
					if #entry.stasis[id] ~= 0 then
						local status, err = pcall(ent[val[2]], ent, unpack(entry.stasis[id]))
						
						if not status then
							print(err)
							print(debug.traceback())
						end
					end
				end
				
				ent:Spawn()
				
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
				
				ent:Activate()
				
				if ent.Flashback_PropID then
					VALID_PROPS[ent.Flashback_PropID] = ent
					VALID_PROPS_SOUNDS[ent.Flashback_PropID] = ent
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
					ent:EmitSound(
						vals.SoundName or vals.OriginalSoundName,
						vals.SoundLevel or 75,
						vals.Pitch or 100,
						vals.Volume or 1,
						vals.Channel
					)
				end
			end
		end
	}
}

local function OnEntityCreated(ent)
	if not self.IsRecording then return end
	
	local time = self.GetCurrentFrame().CurTime
	local data = self.GetCurrentData('DFlashback.Default.ents')
	data.FrameProps = data.FrameProps or {}
	
	timer.Simple(0, function()
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
	
	local data = self.GetCurrentData('DFlashback.Default.ents_restore')
	data.ToRestore = data.ToRestore or {}
	local entry = {}
	table.insert(data.ToRestore, entry)
	
	entry.class = ent:GetClass()
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
	if not CheckEntitySound(ent) then return end
	
	ent.Flashback_PropID = ent.Flashback_PropID or math.random(1, 10000)
	VALID_PROPS_SOUNDS[ent.Flashback_PropID] = ent
	local uid = ent.Flashback_PropID
	
	local data = self.GetCurrentData('DFlashback.Default.sounds')
	
	data.sounds = data.sounds or {}
	data.sounds[uid] = data.sounds[uid] or {}
	
	table.insert(data.sounds[uid], table.Copy(soundData))
end

hook.Add('OnEntityCreated', 'DFlashback.Default.PropDelete', OnEntityCreated)
hook.Add('EntityRemoved', 'DFlashback.Default.RestoreEntity', EntityRemoved)
hook.Add('EntityEmitSound', 'DFlashback.Default.Sounds', EntityEmitSound)

for k, v in pairs(Default) do
	hook.Add('FlashbackRecordFrame', 'DFlashback.Default.' .. k, v.record)
	hook.Add('FlashbackRestoreFrame', 'DFlashback.Default.' .. k, v.replay)
	hook.Add('FlashbackStartsRestore', 'DFlashback.Default.' .. k, v.starts_replay)
	hook.Add('FlashbackEndsRestore', 'DFlashback.Default.' .. k, v.ends_replay)
end
