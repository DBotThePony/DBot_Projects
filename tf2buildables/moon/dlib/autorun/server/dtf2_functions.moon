
--
-- Copyright (C) 2017-2018 DBot

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
