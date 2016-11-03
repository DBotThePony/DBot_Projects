
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

timer.Create('DFlashback.Default.UpdatePropList', 1, 0, function()
	if not self.IsRecording then return end
	
	VALID_PROPS = {}
	
	for k, v in ipairs(ents.GetAll()) do
		local cond = v:GetSolid() == SOLID_NONE or
			v:CreatedByMap() or
			v:IsNPC() or
			v:IsWeapon() or
			v:IsPlayer()
			
		if not cond then
			v.Flashback_PropID = v.Flashback_PropID or math.random(1, 10000)
			VALID_PROPS[v.Flashback_PropID] = v
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
	
	props = {
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
					-- self.WriteDelta(myKey, uid .. 'mass', phys:GetMass())
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
					-- phys:SetMass(self.WriteDelta(myKey, uid .. 'mass', phys:GetMass()) or 0)
				end
			end
		end,
	},
	
	ents_restore = {
		replay = function(data, myKey)
			if not data.ToRestore then return end
			
			for i, entry in ipairs(data.ToRestore) do
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
				
				ent:Activate()
				
				if ent.Flashback_PropID then
					VALID_PROPS[ent.Flashback_PropID] = ent
				end
			end
		end,
	}
}

local function OnEntityCreated(ent)
	if not self.IsRecording then return end
	local time = CurTime()
	
	timer.Simple(0, function()
		ent.FlashbackTimeSpawned = time
		table.insert(VALID_PROPS, ent)
	end)
end

local function EntityRemoved(ent)
	if not self.IsRecording then return end
	
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

hook.Add('OnEntityCreated', 'DFlashback.Default.PropDelete', OnEntityCreated)
hook.Add('EntityRemoved', 'DFlashback.Default.RestoreEntity', EntityRemoved)

for k, v in pairs(Default) do
	hook.Add('FlashbackRecordFrame', 'DFlashback.Default.' .. k, v.record)
	hook.Add('FlashbackRestoreFrame', 'DFlashback.Default.' .. k, v.replay)
	hook.Add('FlashbackStartsRestore', 'DFlashback.Default.' .. k, v.starts_replay)
	hook.Add('FlashbackEndsRestore', 'DFlashback.Default.' .. k, v.ends_replay)
end
