
--
-- Copyright (C) 2017-2019 DBotThePony

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


AddCSLuaFile()

DEFINE_BASECLASS('dbot_tf_scattergun')

SWEP.Base = 'dbot_tf_scattergun'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2 Scout'
SWEP.PrintName = 'Back Scatter'
SWEP.ViewModel = 'models/weapons/c_models/c_scout_arms.mdl'
SWEP.WorldModel = 'models/workshop/weapons/c_models/c_scatterdrum/c_scatterdrum.mdl'
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.RandomCriticals = false

SWEP.DefaultSpread = Vector(1, 1, 0) * 0.055

SWEP.PreOnHit = (hitEntity = NULL, tr = {}, dmginfo) =>
	@BaseClass.PreOnHit(@, hitEntity, tr, dmginfo)
	if hitEntity\IsValid() and hitEntity\GetPos()\Distance(@GetOwner()\GetPos()) < 500 and @AttackingAtSpine(hitEntity)
		@ThatWasMinicrit(hitEntity, dmginfo)

SWEP.FireSoundsScript = 'Weapon_Back_Scatter.Single'
SWEP.FireCritSoundsScript = 'Weapon_Back_Scatter.SingleCrit'
SWEP.EmptySoundsScript = 'Weapon_Back_Scatter.Empty'

SWEP.Primary = {
	'Ammo': 'Buckshot'
	'ClipSize': 4
	'DefaultClip': 4
	'Automatic': true
}

