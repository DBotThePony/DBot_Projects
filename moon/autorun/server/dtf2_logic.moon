
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

export DTF2_GiveAmmo

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

DTF2_GiveAmmo = (weightThersold = 40) =>
    return 0 if weightThersold <= 0
    return 0 if not IsValid(@)
    return 0 if not @IsPlayer()
    oldWeight = weightThersold

    for {:name, :weight, :maximal, :nominal} in *AMMO_TO_GIVE
        count = @GetAmmoCount(name)
        continue if count >= maximal
        deltaNeeded = math.Clamp(maximal - count, 0, math.min(nominal, weightThersold / weight))
        continue if deltaNeeded == 0
        weightedDelta = deltaNeeded * weight
        continue if weightedDelta > weightThersold
        weightThersold -= weightedDelta
        @GiveAmmo(deltaNeeded, name)
        return oldWeight if weightedDelta <= 0
    
    return oldWeight - weightThersold
