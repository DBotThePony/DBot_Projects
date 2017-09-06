
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

EFFECT.Init = (effData) =>
	pos = effData\GetOrigin()
	ang = effData\GetNormal()\Angle()
	ParticleEffect('drg_cow_explosion_coreflash', pos, ang)
	ParticleEffect('drg_cow_explosion_flashup', pos, ang)
	ParticleEffect('drg_cow_explosion_flash_1', pos, ang)
	ParticleEffect('drg_cow_explosion_smoke', pos, ang)
	ParticleEffect('drg_cow_explosion_sparkles', pos, ang)
	ParticleEffect('drg_cow_explosion_sparkles_charged', pos, ang)
	ParticleEffect('drg_cow_explosion_sparks', pos, ang)
	ParticleEffect('Explosion_CoreFlash', pos, ang)
	ParticleEffect('Explosion_Dustup', pos, ang)
	ParticleEffect('Explosion_Dustup_2', pos, ang)
	ParticleEffect('Explosion_Smoke_1', pos, ang)
	ParticleEffect('Explosion_Flashup', pos, ang)
	util.Decal('DTF2_RocketExplosion', effData\GetOrigin() + effData\GetNormal(), effData\GetOrigin() - effData\GetNormal())

EFFECT.Think = => false
EFFECT.Render = =>
