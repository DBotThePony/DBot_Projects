
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


AddCSLuaFile()

SWEP.Base = 'dbot_tf_fireaxe'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2 Pyro'
SWEP.PrintName = 'Third Degree'
SWEP.ViewModel = 'models/weapons/c_models/c_pyro_arms.mdl'
SWEP.WorldModel = 'models/weapons/c_models/c_drg_thirddegree/c_drg_thirddegree.mdl'
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false

SWEP.MissSoundsScript = 'Weapon_FireAxe.Miss'
SWEP.MissCritSoundsScript = 'Weapon_FireAxe.MissCrit'
SWEP.HitSoundsScript = 'Weapon_3rd_degree.HitWorld'
SWEP.HitSoundsFleshScript = 'Weapon_3rd_degree.HitFlesh'
