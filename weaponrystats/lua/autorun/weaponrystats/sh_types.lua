
-- Copyright (C) 2017 DBot

-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at

--     http://www.apache.org/licenses/LICENSE-2.0

-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

return {
	poison = {
		name = 'Poision',
		dmgtype = DMG_POISON,
		isAdditional = false,
		damage = 1.1,
		force = 1,
		quality = 1,
		speed = 1,
		order = -10
	},

	electric = {
		name = 'Shocking',
		dmgtype = DMG_SHOCK,
		isAdditional = false,
		damage = 1.25,
		force = 0.4,
		quality = 2,
		speed = 1,
		order = 10
	},

	plasma = {
		name = 'Heating',
		dmgtype = DMG_PLASMA,
		isAdditional = false,
		damage = 1.25,
		force = 0.2,
		quality = 3,
		speed = 0.9,
		order = 20
	},

	dissolve = {
		name = 'Dissolving',
		dmgtype = DMG_DISSOLVE,
		isAdditional = false,
		damage = 1.4,
		force = 1.4,
		quality = 4,
		speed = 0.8,
		order = 60
	},

	ethernal = {
		name = 'Ethereal Damage',
		dmgtype = DMG_DISSOLVE,
		isAdditional = true,
		damage = 0.2,
		force = 1,
		quality = 4,
		speed = 1.1,
		order = 50
	},

	radiation = {
		name = 'Radiation',
		dmgtype = DMG_RADIATION,
		isAdditional = false,
		damage = 1.4,
		force = 1,
		quality = 4,
		speed = 1,
		order = 70
	},

	toxic = {
		name = 'Toxic Gases',
		dmgtype = DMG_NERVEGAS,
		isAdditional = false,
		damage = 1.1,
		force = 0.4,
		quality = 4,
		speed = 1.4,
		order = 60
	},

	pellets = {
		name = 'Capercaillie',
		dmgtype = DMG_BUCKSHOT,
		isAdditional = false,
		damage = 1.3,
		force = 2,
		quality = 1,
		speed = 0.9,
		order = 10
	},

	ghost = {
		name = 'Ghost Hit',
		dmgtype = DMG_VEHICLE,
		isAdditional = true,
		damage = 0.4,
		force = 10,
		quality = 4,
		speed = 0.75,
		order = 75
	},

	shooting = {
		name = 'Fusillade',
		dmgtype = DMG_BULLET,
		isAdditional = false,
		damage = 0.9,
		force = 0.85,
		quality = 3,
		speed = 1.5,
		order = 50
	},

	unknown = {
		name = 'Unknown?',
		dmgtype = DMG_GENERIC,
		isAdditional = false,
		damage = 1.4,
		force = 4,
		quality = 6,
		speed = 1.5,
		order = 110
	},

	fire = {
		name = 'Flaming',
		dmgtype = DMG_BURN,
		isAdditional = false,
		damage = 1.3,
		force = 0.2,
		quality = 3,
		speed = 1.1,
		order = 70
	},

	frying = {
		name = 'Frying',
		dmgtype = DMG_BURN,
		isAdditional = true,
		damage = 0.2,
		force = 0.3,
		quality = 2,
		speed = 1,
		order = 20
	},

	acid = {
		name = 'Digesting',
		dmgtype = DMG_ACID,
		isAdditional = true,
		damage = 0.1,
		force = 1,
		quality = 3,
		speed = 1.1,
		order = 40
	},

	beam = {
		name = 'Burn out',
		dmgtype = DMG_ENERGYBEAM,
		isAdditional = false,
		damage = 1.3,
		force = 0,
		quality = 3,
		speed = 1.3,
		order = 25
	},

	damaging = {
		name = 'Damaging',
		dmgtype = DMG_AIRBOAT,
		isAdditional = true,
		damage = 0.1,
		force = 2,
		quality = 4,
		speed = 0.9,
		order = 75
	},

	destructing = {
		name = 'DESTRUCTION',
		dmgtype = DMG_AIRBOAT,
		isAdditional = false,
		damage = 1.3,
		force = 6,
		quality = 7,
		speed = 1.1,
		order = 110
	},

	penetrating = {
		name = 'Penetrating',
		dmgtype = DMG_DIRECT,
		isAdditional = true,
		damage = 0.1,
		force = 3,
		quality = 6,
		speed = 0.8,
		order = 100
	},

	destroyer = {
		name = 'Destroying',
		dmgtype = DMG_DIRECT,
		isAdditional = false,
		damage = 0.7,
		force = 5,
		quality = 7,
		speed = 0.9,
		order = 100
	},

	blast = {
		name = 'Blasting',
		dmgtype = DMG_BLAST,
		isAdditional = false,
		damage = 1.4,
		force = 3,
		quality = 3,
		speed = 1,
		order = 30
	},

	club = {
		name = 'Slashing',
		dmgtype = DMG_CLUB,
		isAdditional = true,
		damage = 0.1,
		force = 1,
		quality = 1,
		speed = 1,
		order = 10
	},

	sonic = {
		name = 'SOUND',
		dmgtype = DMG_SONIC,
		isAdditional = false,
		damage = 1.1,
		force = 5,
		quality = 3,
		speed = 1,
		order = 25
	},

	wave = {
		name = 'SOUND WAVES',
		dmgtype = DMG_SONIC,
		isAdditional = true,
		damage = 0.2,
		force = 2,
		quality = 3,
		speed = 1,
		order = 30
	},

	usual = {
		name = 'usualness',
		dmgtype = DMG_BLAST,
		isAdditional = true,
		damage = 0,
		force = 1,
		quality = 0,
		speed = 1,
		order = 0
	},
}
