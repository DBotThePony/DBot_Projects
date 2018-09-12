
--
-- Copyright (C) 2017 DBot

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


ENT.PrintName = 'Crystalization'
ENT.Author = 'DBot'
ENT.Type = 'point'

import ents, IsValid, CurTime, math from _G

v\Remove() for v in *ents.FindByClass('dbot_scp409_killer')
v\Remove() for v in *ents.FindByClass('dbot_scp409_fragment')

ENT.Think = =>
	if CLIENT return
	obj = @GetParent()
	
	if not IsValid(obj)
		@Remove() 
		return
	elseif obj\IsPlayer() and not obj\Alive()
		@Remove() 
		return
	
	dmg = DamageInfo()
	
	dmg\SetDamage(math.max(10, obj\Health() * .1))
	dmg\SetAttacker(IsValid(@Crystal) and @Crystal or @)
	dmg\SetInflictor(@)
	dmg\SetDamageType(DMG_ACID)
	obj\TakeDamageInfo(dmg)
	
	if obj\IsPlayer() then obj\GodDisable()
	@NextThink(CurTime() + .3)
	return true

ENT.OnRemove = =>
	for i = 1, math.random(1, 4)
		ent = ents.Create('dbot_scp409_fragment')
		with ent
			\SetPos(@GetPos())
			\Spawn()
			\Push()
			.Crystal = @Crystal
	if not IsValid(@GetParent()) return
	@GetParent().CRYSTALIZING = false
