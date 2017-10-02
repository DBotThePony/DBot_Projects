
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
		name = 'Poison',
		dmgtype = DMG_POISON,
		isAdditional = false,
		damage = 1.1,
		force = 1,
		clip = 1.1,
		scatter = 1,
		scatterAdd = Vector(0.000, 0.000, 0),
		num = 1,
		numAdd = 0,
		quality = 1,
		speed = 1,
		order = -10
	},

	electric = {
		name = 'Shock',
		dmgtype = DMG_SHOCK,
		isAdditional = false,
		damage = 1.25,
		force = 0.4,
		clip = 1,
		scatter = 1,
		scatterAdd = Vector(0.000, 0.000, 0),
		num = 1,
		numAdd = 0,
		quality = 2,
		speed = 1,
		order = 10,
		bullet = 'dbot_bullet_shock'
	},

	watts = {
		name = 'Electricity',
		dmgtype = DMG_SHOCK,
		isAdditional = true,
		damage = 0.5,
		force = 0,
		clip = 1.1,
		scatter = 1.2,
		scatterAdd = Vector(0.001, 0.001, 0),
		num = 1,
		numAdd = 0,
		quality = 5,
		speed = 1.3,
		order = 80,
		bullet = 'dbot_bullet_shock'
	},

	choke = {
		name = 'Choking',
		dmgtype = DMG_DROWN,
		isAdditional = true,
		damage = 0.1,
		force = 1.4,
		clip = 1.1,
		scatter = 1,
		scatterAdd = Vector(0.000, 0.000, 0),
		num = 1,
		numAdd = 0,
		quality = 3,
		speed = 1,
		order = 40
	},

	water = {
		name = 'Water',
		dmgtype = DMG_DROWN,
		isAdditional = false,
		damage = 0.35,
		force = 0,
		clip = 0.8,
		scatter = 1.1,
		scatterAdd = Vector(0.000, 0.000, 0),
		num = 1,
		numAdd = 0,
		quality = -2,
		speed = 1.65,
		order = 40
	},

	gas_weak = {
		name = 'Teardrops',
		dmgtype = DMG_NERVEGAS,
		isAdditional = false,
		damage = 0.5,
		force = 0,
		clip = 1,
		scatter = 1.1,
		scatterAdd = Vector(0.000, 0.000, 0),
		num = 1,
		numAdd = 0,
		quality = -1,
		speed = 1.2,
		order = 40
	},

	musket_bullets = {
		name = 'Musket bullets',
		dmgtype = DMG_BULLET,
		isAdditional = false,
		damage = 0.65,
		force = 0.3,
		clip = 1.4,
		scatter = 1.3,
		scatterAdd = Vector(0.000, 0.000, 0),
		num = 1.3,
		numAdd = 0,
		quality = -2,
		speed = 0.85,
		order = 40
	},

	laugh = {
		name = 'Laugh',
		dmgtype = DMG_PARALYZE,
		isAdditional = false,
		damage = 0.35,
		force = 0,
		clip = 0.85,
		scatter = 1.15,
		scatterAdd = Vector(0.009, 0.009, 0),
		num = 1.3,
		numAdd = 0,
		quality = -4,
		speed = 1.35,
		order = 30
	},

	laugh = {
		name = 'Pneumatics',
		dmgtype = DMG_BUCKSHOT,
		isAdditional = false,
		damage = 0.4,
		force = 0.2,
		clip = 0.6,
		scatter = 0.6,
		scatterAdd = Vector(0.00, 0.00, 0),
		num = 1,
		numAdd = 0,
		quality = -7,
		speed = 0.6,
		order = 64
	},

	h2 = {
		name = 'Hydrogen',
		dmgtype = DMG_BLAST,
		isAdditional = false,
		damage = 0.55,
		force = 0.2,
		clip = 0.85,
		scatter = 1.25,
		scatterAdd = Vector(0.00, 0.00, 0),
		num = 1.25,
		numAdd = 0,
		quality = -3,
		speed = 0.6,
		order = 64
	},

	plasma = {
		name = 'Heating',
		dmgtype = DMG_PLASMA,
		isAdditional = false,
		damage = 1.25,
		force = 0.2,
		clip = 1.2,
		scatter = 0.7,
		scatterAdd = Vector(0.000, 0.000, 0),
		num = 0.8,
		numAdd = 0,
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
		clip = 0.8,
		scatter = 0.4,
		scatterAdd = Vector(0.000, 0.000, 0),
		num = 1,
		numAdd = 0,
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
		clip = 0.95,
		scatter = 1,
		scatterAdd = Vector(0.000, 0.000, 0),
		num = 1,
		numAdd = 0,
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
		clip = 0.8,
		scatter = 1,
		scatterAdd = Vector(0.000, 0.000, 0),
		num = 0.75,
		numAdd = 0,
		quality = 4,
		speed = 1,
		order = 70
	},

	toxic = {
		name = 'Toxic Gases',
		dmgtype = DMG_NERVEGAS,
		isAdditional = false,
		damage = 0.9,
		force = 0.4,
		clip = 1.15,
		scatter = 1,
		scatterAdd = Vector(0.000, 0.000, 0),
		num = 1,
		numAdd = 0,
		quality = 4,
		speed = 1.4,
		order = 60
	},

	pellets = {
		name = 'Capercaillie',
		dmgtype = DMG_BUCKSHOT,
		isAdditional = false,
		damage = 1.4,
		force = 2,
		clip = 0.9,
		scatter = 1.2,
		scatterAdd = Vector(0.001, 0.001, 0),
		num = 1.5,
		numAdd = 0,
		quality = 4,
		speed = 0.9,
		order = 40
	},

	ghost = {
		name = 'Ghost Hit',
		dmgtype = DMG_VEHICLE,
		isAdditional = true,
		damage = 0.4,
		force = 10,
		clip = 0.95,
		scatter = 1,
		scatterAdd = Vector(0.000, 0.000, 0),
		num = 1,
		numAdd = 0,
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
		clip = 1.25,
		scatter = 1.1,
		scatterAdd = Vector(0.000, 0.000, 0),
		num = 1,
		numAdd = 0,
		quality = 4,
		speed = 1.5,
		order = 50
	},

	unknown = {
		name = 'Unknown?',
		dmgtype = DMG_GENERIC,
		isAdditional = false,
		damage = 1.3,
		force = 4,
		clip = 0.9,
		scatter = 1,
		scatterAdd = Vector(0.000, 0.000, 0),
		num = 1,
		numAdd = 0,
		quality = 5,
		speed = 1.5,
		order = 80
	},

	new_weapon = {
		name = 'New Technology MK 1',
		dmgtype = DMG_BULLET + DMG_SLASH + DMG_BURN,
		isAdditional = false,
		damage = 1.5,
		force = 8,
		clip = 1.1,
		scatter = 1.2,
		scatterAdd = Vector(0.000, 0.000, 0),
		num = 1,
		numAdd = 0,
		quality = 7,
		speed = 1.25,
		order = 110
	},

	new_weapon2 = {
		name = 'New Technology MK 2',
		dmgtype = DMG_BULLET + DMG_SLASH + DMG_VEHICLE + DMG_ENERGYBEAM,
		isAdditional = false,
		damage = 1.25,
		force = 12,
		clip = 1.2,
		scatter = 1.15,
		scatterAdd = Vector(0.000, 0.000, 0),
		num = 1,
		numAdd = 0,
		quality = 9,
		speed = 1.3,
		order = 120
	},

	new_weapon3 = {
		name = 'New Technology MK 3',
		dmgtype = DMG_BULLET + DMG_PARALYZE + DMG_ACID + DMG_NERVEGAS,
		isAdditional = false,
		damage = 1.6,
		force = 4,
		clip = 0.75,
		scatter = 1.1,
		scatterAdd = Vector(0.000, 0.000, 0),
		num = 1,
		numAdd = 0,
		quality = 9,
		speed = 1.1,
		order = 120
	},

	fire = {
		name = 'Bust into Flames',
		dmgtype = DMG_BURN,
		isAdditional = false,
		damage = 0.8,
		force = 0.2,
		clip = 1.25,
		scatter = 1,
		scatterAdd = Vector(0.000, 0.000, 0),
		num = 1,
		numAdd = 0,
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
		clip = 1,
		scatter = 1,
		scatterAdd = Vector(0.000, 0.000, 0),
		num = 1,
		numAdd = 0,
		quality = 2,
		speed = 1,
		order = 20
	},

	acid = {
		name = 'Digesting',
		dmgtype = DMG_ACID,
		isAdditional = true,
		damage = 0.25,
		force = 1,
		clip = 0.75,
		scatter = 1,
		scatterAdd = Vector(0.000, 0.000, 0),
		num = 1,
		numAdd = 0,
		quality = 3,
		speed = 1.1,
		order = 40
	},

	beam = {
		name = 'Burn out',
		dmgtype = DMG_ENERGYBEAM,
		isAdditional = false,
		damage = 0.9,
		force = 0,
		clip = 1.4,
		scatter = 0.75,
		scatterAdd = Vector(0.000, 0.000, 0),
		num = 1.3,
		numAdd = 0,
		quality = 4,
		speed = 1.3,
		order = 50
	},

	damaging = {
		name = 'Damaging',
		dmgtype = DMG_AIRBOAT,
		isAdditional = true,
		damage = 0.1,
		force = 2,
		clip = 1,
		scatter = 1,
		scatterAdd = Vector(0.000, 0.000, 0),
		num = 1,
		numAdd = 0,
		quality = 4,
		speed = 0.9,
		order = 75
	},

	destructing = {
		name = 'DESTRUCTION',
		dmgtype = DMG_AIRBOAT + DMG_DIRECT,
		isAdditional = false,
		damage = 1.3,
		force = 6,
		clip = 0.75,
		scatter = 1.25,
		scatterAdd = Vector(0.001, 0.001, 0),
		num = 1,
		numAdd = 0,
		quality = 7,
		speed = 1.2,
		order = 110
	},

	penetrating = {
		name = 'Penetrating',
		dmgtype = DMG_DIRECT,
		isAdditional = true,
		damage = 0.15,
		clip = 0.8,
		scatter = 1.1,
		scatterAdd = Vector(0.000, 0.000, 0),
		num = 1,
		numAdd = 0,
		force = 3,
		quality = 5,
		speed = 0.8,
		order = 60
	},

	destroyer = {
		name = 'Destroying',
		dmgtype = DMG_DIRECT,
		isAdditional = false,
		damage = 0.7,
		force = 5,
		clip = 0.9,
		scatter = 0.5,
		scatterAdd = Vector(0.000, 0.000, 0),
		num = 1,
		numAdd = 0,
		quality = 7,
		speed = 0.8,
		order = 100
	},

	blast = {
		name = 'Blasting',
		dmgtype = DMG_BLAST,
		isAdditional = false,
		damage = 1.35,
		force = 3,
		clip = 1.1,
		scatter = 1.2,
		scatterAdd = Vector(0.000, 0.000, 0),
		num = 1,
		numAdd = 0,
		quality = 3,
		speed = 0.9,
		order = 30
	},

	club = {
		name = 'Slashing',
		dmgtype = DMG_CLUB,
		isAdditional = true,
		damage = 0.1,
		force = 1,
		clip = 1,
		scatter = 1,
		scatterAdd = Vector(0.000, 0.000, 0),
		num = 1,
		numAdd = 0,
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
		clip = 1.2,
		scatter = 1.3,
		scatterAdd = Vector(0.000, 0.000, 0),
		num = 1,
		numAdd = 0,
		quality = 3,
		speed = 1.1,
		order = 25
	},

	wave = {
		name = 'SOUND WAVES',
		dmgtype = DMG_SONIC,
		isAdditional = true,
		damage = 0.2,
		force = 2,
		clip = 1,
		scatter = 1.1,
		scatterAdd = Vector(0.000, 0.000, 0),
		num = 1,
		numAdd = 0,
		quality = 3,
		speed = 1.1,
		order = 30
	},

	usual = {
		name = 'Usualness',
		dmgtype = DMG_BULLET,
		isAdditional = true,
		damage = 0,
		clip = 1,
		scatter = 1,
		scatterAdd = Vector(0.000, 0.000, 0),
		num = 1,
		numAdd = 0,
		force = 1,
		quality = 0,
		speed = 1,
		order = 0
	},

	usual = {
		name = 'Dissapear',
		dmgtype = DMG_NEVERGIB + DMG_REMOVENORAGDOLL,
		isAdditional = false,
		damage = 1.1,
		clip = 1,
		scatter = 1,
		scatterAdd = Vector(0.000, 0.000, 0),
		num = 1,
		numAdd = 0,
		force = 1,
		quality = 2,
		speed = 1,
		order = 20
	},

	alien = {
		name = 'Alien bullets',
		dmgtype = DMG_DISSOLVE,
		isAdditional = false,
		damage = 1.25,
		clip = 1,
		scatter = 1,
		scatterAdd = Vector(0.000, 0.000, 0),
		num = 1,
		numAdd = 0,
		force = 1,
		quality = 3,
		speed = 1,
		order = 40
	},

	heated = {
		name = 'Heated plasma',
		dmgtype = DMG_PLASMA,
		isAdditional = false,
		damage = 1.3,
		clip = 0.8,
		scatter = 1.1,
		scatterAdd = Vector(0.000, 0.000, 0),
		num = 1,
		numAdd = 0,
		force = 1,
		quality = 5,
		speed = 1.3,
		order = 60
	},

	velocity = {
		name = 'Hight Velocity Bullets',
		dmgtype = DMG_NEVERGIB + DMG_SLASH,
		isAdditional = false,
		damage = 1.8,
		clip = 0.9,
		scatter = 0.4,
		num = 1,
		numAdd = 0,
		force = 8,
		quality = 6,
		speed = 1.1,
		order = 60,
		bullet = 'dbot_bullet_high'
	},
}
