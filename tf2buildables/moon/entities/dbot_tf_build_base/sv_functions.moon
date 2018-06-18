
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

_G.DTF2 = _G.DTF2 or {}
DTF2 = _G.DTF2

ENT.CreateBullseye = =>
	if @npc_bullseye
		eye\Remove() for {eye} in *@npc_bullseye when IsValid(eye)

	mins, maxs, center = @OBBMins(), @OBBMaxs(), @OBBCenter()

	box = {
		Vector(0, 0, mins.z)
		Vector(0, 0, maxs.z)

		Vector(mins.x, center.y, center.z)
		Vector(-mins.x, center.y, center.z)

		Vector(center.x, mins.y, center.z)
		Vector(center.x, -mins.y, center.z)
	}

	@npc_bullseye = for vec in *box
		ent = ents.Create('npc_bullseye')
		with ent
			\SetKeyValue('targetname', 'dtf2_bullseye')
			\SetKeyValue('spawnflags', '131072')
			\SetPos(@LocalToWorld(vec))
			\Spawn()
			\Activate()
			\SetCollisionGroup(COLLISION_GROUP_WORLD)
			\SetHealth(2 ^ 31 - 1)
			\SetParent(@)
			\SetNotSolid(true)
			.DTF2_Parent = @
			.DTF2_LastDMG = 0
		{ent, DTF2.Pointer(ent)}
