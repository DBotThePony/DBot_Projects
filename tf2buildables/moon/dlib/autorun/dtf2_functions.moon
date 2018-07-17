
--
-- Copyright (C) 2017-2018 DBot
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

export DTF2
DTF2 = DTF2 or {}

if CLIENT
	DLib.RegisterAddonName('TF2 Buildables')

BOOL_OR_FUNC = (val, undef = true, ...) ->
	switch type(val)
		when 'function'
			return val(...)
		when 'nil'
			return undef
		else
			return val

DTF2.IsValidTarget = =>
	IsValid(@) and ((@IsPlayer() or @IsNPC() or @IsTF2Building) or (
	not BOOL_OR_FUNC(@IsDroneDestroyed, false, @) and
	BOOL_OR_FUNC(@IsDestroyed, true, @) and
	BOOL_OR_FUNC(@IsWorking, true, @) and
	(@GetMaxHealth() <= 0 or @Health() > 0) and
	(BOOL_OR_FUNC(@GetMaxHP, 0, @) <= 0 or BOOL_OR_FUNC(@GetHP, 1, @) > 0)))

DTF2.Pointer = => string.format('%p', @)

DTF2.TableRandom = (tab, id = 'dtf2_prediction') ->
	valids = [val for val in *tab when type(val) ~= 'table']
	return nil if #valids == 0
	rand = math.floor(util.SharedRandom('dtf2', 1, #valids * 100, CurTime()) / 100 + 0.5)
	return valids[rand]

DTF2.ApplyVelocity = (ent, vel) ->
	if not ent\IsPlayer() and not ent\IsNPC()
		for i = 0, ent\GetPhysicsObjectCount() - 1
			phys = ent\GetPhysicsObjectNum(i)
			phys\AddVelocity(vel) if IsValid(phys)
	else
		ent\SetVelocity(vel + Vector(0, 0, 100))

DTF2.PlayCritEffect = (hitEntity) ->
	mins, maxs = hitEntity\GetRotatedAABB(hitEntity\OBBMins(), hitEntity\OBBMaxs())
	pos = hitEntity\GetPos()
	newZ = math.max(pos.z, pos.z + mins.z, pos.z + maxs.z)
	pos.z = newZ

	effData = EffectData()
	effData\SetOrigin(pos)
	util.Effect('dtf2_critical_hit', effData)
	hitEntity\EmitSound('DTF2_TFPlayer.CritHit')

DTF2.PlayMiniCritEffect = (hitEntity) ->
	mins, maxs = hitEntity\GetRotatedAABB(hitEntity\OBBMins(), hitEntity\OBBMaxs())
	pos = hitEntity\GetPos()
	newZ = math.max(pos.z, pos.z + mins.z, pos.z + maxs.z)
	pos.z = newZ

	effData = EffectData()
	effData\SetOrigin(pos)
	util.Effect('dtf2_minicrit', effData)
	hitEntity\EmitSound('DTF2_TFPlayer.CritHitMini')

DTF2.GrabInt = (obj, def = 0) ->
	switch type(obj)
		when 'ConVar'
			obj\GetInt() or math.floor(tonumber(obj\GetDefault()))
		when 'number'
			math.floor(obj)
		when 'string'
			math.floor(tonumber(obj) or def)

DTF2.GrabFloat = (obj, def = 0) ->
	switch type(obj)
		when 'ConVar'
			obj\GetFloat() or tonumber(obj\GetDefault())
		when 'number'
			obj
		when 'string'
			tonumber(obj) or def

DTF2.GrabBool = (obj, def = false) ->
	switch type(obj)
		when 'ConVar'
			obj\GetBool()
		when 'nil'
			def
		when 'boolean'
			obj
		when 'string', 'number'
			tobool(obj)
