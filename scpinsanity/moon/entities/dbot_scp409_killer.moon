
--
-- Copyright (C) 2017 DBot
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

ENT.PrintName = 'Crystalization'
ENT.Author = 'DBot'
ENT.Type = 'point'

import ents, IsValid, CurTime, math from _G

v\Remove() for v in *ents.FindByClass('dbot_scp409_killer')
v\Remove() for v in *ents.FindByClass('dbot_scp409_fragment')

ENT.Think = =>
	if CLIENT return
	obj = @GetParent()
	
	if not IsValid(obj) then 
		@Remove() 
		return
	elseif obj\IsPlayer() and not obj\Alive() then 
		@objRemove() 
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
