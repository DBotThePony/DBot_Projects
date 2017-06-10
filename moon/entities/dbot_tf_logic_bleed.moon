

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

ENT.Type = 'anim'
ENT.PrintName = 'Bleeding Logic'
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.Author = 'DBot'
ENT.RenderGroup = RENDERGROUP_OTHER

if SERVER
    entMeta = FindMetaTable('Entity')

    entMeta.TF2Bleed = (duration = 0) =>
        return @__dtf2_bleed_logic if IsValid(@__dtf2_bleed_logic)
        @__dtf2_bleed_logic = ents.Create('dbot_tf_logic_bleed')
        @__dtf2_bleed_logic\SetPos(@GetPos())
        @__dtf2_bleed_logic\Spawn()
        @__dtf2_bleed_logic\Activate()
        @__dtf2_bleed_logic\SetParent(@)
        @__dtf2_bleed_logic\SetOwner(@)
        @__dtf2_bleed_logic\UpdateDuration(duration)
        return @__dtf2_bleed_logic
    
    hook.Add 'PlayerDeath', 'DTF2.BleedLogic', => @__dtf2_bleed_logic\Remove() if IsValid(@__dtf2_bleed_logic)
    hook.Add 'OnNPCKilled', 'DTF2.BleedLogic', => @__dtf2_bleed_logic\Remove() if IsValid(@__dtf2_bleed_logic)

with ENT
    .SetupDataTables = =>
        @NetworkVar('Entity', 0, 'Attacker')
        @NetworkVar('Entity', 1, 'Inflictor')
        @NetworkVar('Float', 0, 'HitDelay')
        @NetworkVar('Float', 1, 'Damage')
    
    .Initialize = =>
        @SetNoDraw(true)
        @SetNotSolid(true)
        @SetHitDelay(.5)
        @SetDamage(4)
        @nextBloodParticle = CurTime()
        return if CLIENT
        @burnStart = CurTime()
        @duration = 4
        @burnEnd = @burnStart + 4
        @SetMoveType(MOVETYPE_NONE)
    
    .UpdateDuration = (newtime = 0) =>
        return if @burnEnd - CurTime() > newtime
        @duration = newtime
        @burnEnd = CurTime() + newtime

    .Think = =>
        return false if CLIENT
        return @Remove() if @burnEnd < CurTime()
        owner = @GetOwner()
        return @Remove() if not IsValid(@GetOwner())
        dmginfo = DamageInfo()
        dmginfo\SetAttacker(IsValid(@GetAttacker()) and @GetAttacker() or @)
        dmginfo\SetInflictor(IsValid(@GetInflictor()) and @GetInflictor() or @)
        dmginfo\SetDamageType(DMG_SLASH)
        dmginfo\SetDamage(@GetDamage())
        owner\TakeDamageInfo(dmginfo)
        @NextThink(CurTime() + @GetHitDelay())
        return true
    
    .OnRemove = => @particles\StopEmission() if @particles and @particles\IsValid()
    .Draw = =>
        return if not IsValid(@GetParent())
        return if @nextBloodParticle > CurTime()
        @nextBloodParticle = CurTime() + @GetHitDelay()
        ent = @GetParent()
        mins, maxs = ent\GetRotatedAABB(ent\OBBMins(), ent\OBBMaxs())

        for i = 1, 4
            randX = math.random(mins.x, maxs.x)
            randY = math.random(mins.y, maxs.y)
            randZ = math.random(mins.z, maxs.z)
            CreateParticleSystem(ent, 'blood_impact_red_01', PATTACH_ABSORIGIN, 0, Vector(randX, randY, randZ))
