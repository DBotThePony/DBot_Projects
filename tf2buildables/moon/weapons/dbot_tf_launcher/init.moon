
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

include 'shared.lua'
AddCSLuaFile 'cl_init.lua'

SWEP.OnFireTriggered = (projectile = NULL) =>
SWEP.FireTrigger = =>
	owner = @GetOwner()
	offset = Vector(@FireOffset)
	offset\Rotate(owner\EyeAngles())
	origin = owner\EyePos() + offset
	aimPos = owner\GetEyeTrace().HitPos
	dir = aimPos - origin
	dir\Normalize()

	with cEnt = ents.Create(@ProjectileClass)
		\SetPos(origin)
		\Spawn()
		\Activate()
		\SetIsMiniCritical(@incomingMiniCrit)   if .SetIsMiniCritical
		\SetIsCritical(@incomingCrit)           if .SetIsCritical
		\SetOwner(@GetOwner())                  if .SetOwner
		\SetAttacker(@GetOwner())               if .SetAttacker
		\SetInflictor(@)                        if .SetInflictor
		\SetWeapon(@)                           if .SetWeapon
		\SetDirection(dir)                      if .SetDirection
		\Think()
		@OnFireTriggered(cEnt)

	@incomingCrit = false
	@incomingMiniCrit = false

