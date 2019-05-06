
--[[
Copyright (C) 2016-2019 DBotThePony


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
		ent:IsVehicle() or
		ent:IsPlayer()

	return not cond
end

local function CheckEntitySound(ent)
	local cond = ent:GetSolid() == SOLID_NONE or
		ent:IsConstraint()

	return not cond
end

local function GetPropID(ent)
	ent.Flashback_PropID = ent.Flashback_PropID or math.random(1, 10000)

	if ent:GetNWInt('FlashBackNetworkID') ~= ent.Flashback_PropID then
		ent:SetNWInt('FlashBackNetworkID', ent.Flashback_PropID)
	end

	return ent.Flashback_PropID
end

timer.Create('DFlashback.Default.UpdatePropList', 1, 0, function()
	if not self.IsRecording then return end

	VALID_PROPS = {}

	for k, v in ipairs(ents.GetAll()) do
		if CheckEntity(v) then
			VALID_PROPS[GetPropID(v)] = v
		end

		if CheckEntitySound(v) then
			VALID_PROPS_SOUNDS[GetPropID(v)] = v
		end
	end
end)

local StasisFuncs = {
	{'GetModel', 'SetModel'},
	{'GetSolid', 'SetSolid'},
	{'GetPos', 'SetPos'},
	{'GetAngles', 'SetAngles'},
	{'GetSkin', 'SetSkin'},
	{'Health', 'SetHealth'},
	{'GetMaterial', 'SetMaterial'},
	{'GetMaxHealth', 'SetMaxHealth'},
}

local DeltaFuncs = {
	{'GetModel', 'SetModel'},
	{'GetPos', 'SetPos'},
	{'GetAngles', 'SetAngles'},
	{'GetSkin', 'SetSkin'},
	{'GetMaterial', 'SetMaterial'},
	{'GetVelocity', 'SetVelocity'},
	{'Health', 'SetHealth'},
	{'GetMaxHealth', 'SetMaxHealth'},
	{'GetColor', 'SetColor'},
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

				data[ply] = {}
				data[ply].weapons = {}
				data[ply].ammos = {}
				data[ply].weapon_data = {}

				for i, weapon in ipairs(ply:GetWeapons()) do
					local class = weapon:GetClass()
					table.insert(data[ply].weapons, class)

					local id1, id2 = weapon:GetPrimaryAmmoType(), weapon:GetSecondaryAmmoType()
					local clip1, clip2 = weapon:Clip1(), weapon:Clip2()
					local amm1, amm2 = ply:GetAmmoCount(id1), ply:GetAmmoCount(id2)

					if id1 and id1 ~= 0 then
						data[ply].ammos[id1] = amm1
					end

					if id2 and id2 ~= 0 then
						data[ply].ammos[id2] = amm2
					end

					table.insert(data[ply].weapon_data, {
						weapon = class,
						clip1 = clip1,
						clip2 = clip2,
						seq = weapon:GetSequence(),
					})
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
				ply:FrameAdvance(self.RealTimeLDelta())

				local currVel = ply:GetVelocity()
				local oldVel = self.FindDelta(myKey, uid .. 'velocity', currVel)

				ply:SetVelocity(oldVel - currVel)

				local get = self.FindDelta(myKey, uid .. 'weaponclass')

				if get then
					ply:SelectWeapon(get)
				end

				if data[ply] then
					local weaponz = {}

					for i, class in ipairs(data[ply].weapons) do
						local weapon = ply:GetWeapon(class)

						if not IsValid(weapon) then
							weapon = ply:Give(class)
						end

						weaponz[class] = weapon

						weapon:FrameAdvance(self.RealTimeLDelta())
					end

					for id, ammo in pairs(data[ply].ammos) do
						ply:SetAmmo(ammo, id)
					end

					for i, weapon in ipairs(ply:GetWeapons()) do
						if not weaponz[weapon:GetClass()] then
							weapon:Remove()
						end
					end

					for i, wepData in ipairs(data[ply].weapon_data) do
						local weapon = weaponz[wepData.weapon]
						weapon:SetClip1(wepData.clip1)
						weapon:SetClip2(wepData.clip2)
						weapon:SetSequence(wepData.seq)
					end
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

				for i, names in ipairs(DeltaFuncs) do
					local status, errOrResult = pcall(v[names[1]], v)

					if status then
						self.WriteDelta(myKey, uid .. ' ' .. i, errOrResult)
					else
						print(errOrResult)
					end
				end

				local phys = v:GetPhysicsObject()

				if phys:IsValid() then
					self.WriteDelta(myKey, uid .. 'motion', phys:IsMotionEnabled())
					self.WriteDelta(myKey, uid .. 'mass', phys:GetMass())
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

				if v.FlashbackTimeSpawned == self.CurTimeL() then
					SafeRemoveEntity(v)
					continue
				end

				for i, names in ipairs(DeltaFuncs) do
					local get = self.FindDelta(myKey, uid .. ' ' .. i)

					if not get then continue end

					local status, get2 = pcall(v[names[1]], v)

					if not status then
						print(err)
					end

					if get2 == get then continue end

					local status, err = pcall(v[names[2]], v, get)

					if not status then
						print(err)
					end
				end

				v:Extinguish()

				local phys = v:GetPhysicsObject()

				if phys:IsValid() then
					phys:EnableMotion(self.FindDelta(myKey, uid .. 'motion', phys:IsMotionEnabled()))
					phys:SetMass(self.FindDelta(myKey, uid .. 'mass', phys:GetMass()))
					phys:Sleep()
				end
			end
		end,

		ends_replay = function()
			for k, ent in pairs(VALID_PROPS) do
				if ent:IsValid() then
					local phys = ent:GetPhysicsObject()

					if IsValid(phys) then
						phys:Wake()
					end
				end
			end
		end,
	},

	ents_restore = {
		replay = function(data, myKey)
			if not data.ToRestore then return end

			for i, entry in ipairs(data.ToRestore) do
				if entry.tab.FlashbackTimeSpawned == self.CurTimeL() then continue end

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
					VALID_PROPS[GetPropID(ent)] = ent
					VALID_PROPS_SOUNDS[ent.Flashback_PropID] = ent
				end

				if IsValid(entry.owner) then
					ent:CPPISetOwner(entry.owner)

					undo.Create('Prop')
					undo.AddEntity(ent)
					undo.SetPlayer(entry.owner)
					undo.Finish()
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

	local time = self.GetCurrentFrame().CurTimeL
	local data = self.GetCurrentData('DFlashback.Default.ents')
	data.FrameProps = data.FrameProps or {}

	timer.Simple(0, function()
		if not CheckEntity(ent) then return end

		ent.Flashback_PropID = ent.Flashback_PropID or math.random(1, 10000)
		ent.FlashbackTimeSpawned = time

		VALID_PROPS[GetPropID(ent)] = ent
		data.FrameProps[GetPropID(ent)] = ent
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

	if ent.CPPIGetOwner then
		entry.owner = ent:CPPIGetOwner()
	end
end

local function EntityEmitSound(soundData)
	if not self.IsRecording then return end
	local ent = soundData.Entity

	if not IsValid(ent) then return end
	if not CheckEntitySound(ent) then return end

	ent.Flashback_PropID = ent.Flashback_PropID or math.random(1, 10000)
	VALID_PROPS_SOUNDS[GetPropID(ent)] = ent
	local uid = ent.Flashback_PropID

	local data = self.GetCurrentData('DFlashback.Default.sounds')

	data.sounds = data.sounds or {}
	data.sounds[uid] = data.sounds[uid] or {}

	table.insert(data.sounds[uid], table.Copy(soundData))
end

hook.Add('OnEntityCreated', 'DFlashback.Default.PropDelete', OnEntityCreated)
hook.Add('EntityRemoved', 'DFlashback.Default.RestoreEntity', EntityRemoved, -1)
hook.Add('EntityEmitSound', 'DFlashback.Default.Sounds', EntityEmitSound)

for k, v in pairs(Default) do
	hook.Add('FlashbackRecordFrame', 'DFlashback.Default.' .. k, v.record)
	hook.Add('FlashbackRestoreFrame', 'DFlashback.Default.' .. k, v.replay)
	hook.Add('FlashbackStartsRestore', 'DFlashback.Default.' .. k, v.starts_replay)
	hook.Add('FlashbackEndsRestore', 'DFlashback.Default.' .. k, v.ends_replay)
end
