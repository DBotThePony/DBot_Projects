
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

resource.AddWorkshop('1129601162')

AMMO_TO_GIVE = {
	{
		'name': 'Pistol'
		'weight': 1
		'maximal': 200
		'nominal': 17
	}

	{
		'name': 'SMG1'
		'weight': 1
		'maximal': 400
		'nominal': 25
	}

	{
		'name': 'ammo_tf_syringe'
		'weight': 1
		'maximal': 160
		'nominal': 25
	}

	{
		'name': 'ammo_tf_flame'
		'weight': 1
		'maximal': 200
		'nominal': 40
	}

	{
		'name': 'Buckshot'
		'weight': 2
		'maximal': 72
		'nominal': 6
	}

	{
		'name': '357'
		'weight': 4
		'maximal': 36
		'nominal': 2
	}

	{
		'name': 'Grenade'
		'weight': 5
		'maximal': 10
		'nominal': 1
	}

	{
		'name': 'ammo_tf_stickybomb'
		'weight': 5
		'maximal': 10
		'nominal': 1
	}

	{
		'name': 'SMG1_Grenade'
		'weight': 4
		'maximal': 12
		'nominal': 1
	}

	{
		'name': 'RPG_Round'
		'weight': 8
		'maximal': 10
		'nominal': 1
	}

	{
		'name': 'XBowBolt'
		'weight': 10
		'maximal': 50
		'nominal': 3
	}

	{
		'name': 'SniperPenetratedRound'
		'weight': 13
		'maximal': 32
		'nominal': 4
	}

	{
		'name': 'SniperRound'
		'weight': 10
		'maximal': 32
		'nominal': 4
	}
}

DTF2.GiveAmmo = (weightThersold = 40) =>
	return 0 if weightThersold <= 0
	return 0 if not IsValid(@)
	return 0 if not @IsPlayer()
	oldWeight = weightThersold
	weightThersold -= @SimulateTF2MetalAdd(weightThersold)
	return oldWeight if weightThersold == 0

	ammoTypes = {}
	for k, weapon in pairs @GetWeapons()
		first, second = game.GetAmmoName(weapon\GetPrimaryAmmoType()), game.GetAmmoName(weapon\GetSecondaryAmmoType())
		ammoTypes[first] = true if first
		ammoTypes[second] = true if second

	for {:name, :weight, :maximal, :nominal} in *AMMO_TO_GIVE
		continue if not ammoTypes[name]
		count = @GetAmmoCount(name)
		continue if count >= maximal
		deltaNeeded = math.Clamp(maximal - count, 0, math.min(nominal, math.floor(weightThersold / weight)))
		continue if deltaNeeded == 0
		weightedDelta = deltaNeeded * weight
		continue if weightedDelta > weightThersold
		weightThersold -= weightedDelta
		@GiveAmmo(deltaNeeded, name)
		return oldWeight if weightedDelta <= 0

	return oldWeight - weightThersold

RAGDOLL_DURATION = CreateConVar('tf_dbg_fake_rag_duration', '25', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Fake ragdolls TTL duration')

DTF2.CreateDeathRagdoll = (duration = RAGDOLL_DURATION\GetFloat()) =>
	with ents.Create('prop_ragdoll')
		\SetPos(@GetPos())
		\SetAngles(@GetAngles())
		\SetModel(@GetModel())
		\Spawn()
		\Activate()
		for boneID = 0, \GetBoneCount() - 1
			physobjID = \TranslateBoneToPhysBone(boneID)
			pos, ang = @GetBonePosition(boneID)
			with o = \GetPhysicsObjectNum(physobjID)
				if IsValid(o)
					-- \SetVelocity(vel)
					\SetMass(300) -- lol
					\SetPos(pos, true) if pos
					\SetAngles(ang) if ang
		\SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		timer.Simple duration, -> \Remove() if \IsValid()

-- yeah from original statue code
DTF2.MakeStatue = =>
	return false if @StatueInfo
	@StatueInfo = {}
	for i = 1, @GetPhysicsObjectCount() - 1
		cnst = constraint.Weld(@, @, 0, i)
		@StatueInfo[i] = cnst if cnst
	@SetNWBool('IsStatue', true)
	return true
