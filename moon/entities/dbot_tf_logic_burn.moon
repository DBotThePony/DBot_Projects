

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
ENT.PrintName = 'Burning Logic'
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.Author = 'DBot'
ENT.RenderGroup = RENDERGROUP_OTHER

entMeta = FindMetaTable('Entity')

if SERVER
    entMeta.TF2Burn = (duration = 0) =>
        if IsValid(@__dtf2_burn_logic)
            @__dtf2_burn_logic\UpdateDuration(duration)
            return @__dtf2_burn_logic
        @__dtf2_burn_logic = ents.Create('dbot_tf_logic_burn')
        @__dtf2_burn_logic\SetPos(@GetPos())
        @__dtf2_burn_logic\Spawn()
        @__dtf2_burn_logic\Activate()
        @__dtf2_burn_logic\SetParent(@)
        @__dtf2_burn_logic\SetOwner(@)
        @__dtf2_burn_logic\UpdateDuration(duration)
        @SetNWEntity('DTF2.BurnLogic', @__dtf2_burn_logic)
        return @__dtf2_burn_logic
    hook.Add 'PlayerDeath', 'DTF2.BurnLogic', => @__dtf2_burn_logic\Remove() if IsValid(@__dtf2_burn_logic)
    hook.Add 'OnNPCKilled', 'DTF2.BurnLogic', => @__dtf2_burn_logic\Remove() if IsValid(@__dtf2_burn_logic)

entMeta.IsTF2Burning = => IsValid(@GetNWEntity('DTF2.BurnLogic'))

with ENT
    .SetupDataTables = =>
        @NetworkVar('Entity', 0, 'Attacker')
        @NetworkVar('Entity', 1, 'Inflictor')
        @NetworkVar('Float', 0, 'HitDelay')
        @NetworkVar('Float', 1, 'Damage')
    
    .Initialize = =>
        @SetNoDraw(true)
        @SetNotSolid(true)
        @SetHitDelay(.75)
        @SetDamage(3)
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
        return if CLIENT
        return @Remove() if @burnEnd < CurTime()
        owner = @GetOwner()
        return @Remove() if not IsValid(@GetOwner())
        dmginfo = DamageInfo()
        dmginfo\SetAttacker(IsValid(@GetAttacker()) and @GetAttacker() or @)
        dmginfo\SetInflictor(IsValid(@GetInflictor()) and @GetInflictor() or @)
        dmginfo\SetDamageType(DMG_BURN)
        dmginfo\SetDamage(@GetDamage())
        owner\TakeDamageInfo(dmginfo)
        @NextThink(CurTime() + @GetHitDelay())
        return true
    
    .OnRemove = => @particles\StopEmission() if @particles and @particles\IsValid()
    .Draw = =>
        return if @particles
        return if not IsValid(@GetParent())
        @particles = CreateParticleSystem(@GetParent(), 'burningplayer_red', PATTACH_ABSORIGIN_FOLLOW)
