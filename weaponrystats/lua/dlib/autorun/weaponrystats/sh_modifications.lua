
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
	broken = {
		name = 'Broken',
		damage = 0.85,
		speed = 0.8,
		force = 0.6,
		clip = 0.9,
		scatter = 1.1,
		num = 0.9,
		quality = -2,
		order = -20
	},

	terrible = {
		name = 'Terrible',
		damage = 0.8,
		speed = 0.8,
		force = 0.9,
		scatter = 1.2,
		scatterAdd = Vector(0.002, 0.002, 0),
		quality = -2,
		order = -20
	},

	annoying = {
		name = 'Annoying',
		damage = 0.85,
		speed = 0.8,
		force = 1,
		clip = 0.9,
		num = 0.9,
		quality = -2,
		order = -20
	},

	slow = {
		name = 'Slow',
		damage = 1,
		speed = 0.9,
		force = 1,
		scatter = 0.8,
		quality = -1,
		order = -10
	},

	quick = {
		name = 'Quick',
		damage = 1,
		speed = 1.2,
		force = 1,
		scatter = 1.1,
		quality = 1,
		order = 5
	},

	deadly = {
		name = 'Deadly',
		damage = 1.1,
		speed = 1.1,
		force = 1,
		quality = 1,
		order = 7
	},

	agile = {
		name = 'Agile',
		damage = 1.1,
		speed = 1.2,
		force = 1,
		scatter = 0.95,
		quality = 2,
		order = 10
	},

	lazy = {
		name = 'Lazy',
		damage = 1,
		speed = 0.75,
		force = 0.9,
		scatter = 1.2,
		quality = -3,
		order = -20
	},
	
	damaged = {
		name = 'Damaged',
		damage = 0.95,
		speed = 0.9,
		force = 0.9,
		scatter = 1.1,
		quality = -3,
		order = -5
	},
	
	shoddy = {
		name = 'Shoddy',
		damage = 0.9,
		speed = 1,
		force = 0.7,
		scatter = 1.25,
		quality = -3,
		order = -10
	},

	keen = {
		name = 'Keen',
		damage = 1.2,
		speed = 1,
		force = 1,
		quality = 1,
		order = 0
	},

	superior = {
		name = 'Superior',
		damage = 1.2,
		speed = 1.1,
		force = 1.2,
		scatter = 0.8,
		num = 1.1,
		quality = 2,
		order = 0
	},

	forceful = {
		name = 'Forceful',
		damage = 1,
		speed = 1,
		force = 1.4,
		scatter = 1.1,
		quality = 1,
		order = 0
	},

	strong = {
		name = 'Strong',
		damage = 1,
		speed = 1,
		force = 1.2,
		quality = 1,
		order = 5
	},

	zealous = {
		name = 'Zealous',
		damage = 1.1,
		speed = 1.2,
		force = 1,
		quality = 1,
		order = 5
	},

	demonic = {
		name = 'Demonic',
		damage = 1.4,
		speed = 1,
		force = 1,
		scatter = 0.95,
		quality = 2,
		order = 20
	},

	godly = {
		name = 'Godly',
		damage = 1.3,
		speed = 1.2,
		force = 1.5,
		clip = 1.15,
		num = 1.2,
		quality = 2,
		order = 20
	},

	unreal = {
		name = 'Unreal',
		damage = 1.4,
		speed = 1.3,
		force = 2,
		quality = 3,
		num = 1.2,
		clip = 1.1,
		order = 30
	},

	legendary = {
		name = 'Legendary',
		damage = 1.5,
		speed = 1.2,
		force = 2.1,
		quality = 3,
		order = 30
	},

	murderous = {
		name = 'Murderous',
		damage = 1.5,
		speed = 1,
		force = 1.5,
		num = 1.1,
		quality = 2,
		order = 15
	},

	handy = {
		name = 'Handy',
		damage = 1,
		speed = 1.75,
		force = 1,
		clip = 1.1,
		quality = 3,
		order = 30
	},

	rapid = {
		name = 'Rapid',
		damage = 1.1,
		speed = 1.5,
		force = 1.2,
		quality = 3,
		order = 30
	},

	vquick = {
		name = 'Quickaer',
		damage = 1,
		speed = 1.9,
		force = 1,
		scatter = 1.1,
		quality = 4,
		order = 40
	},

	vortex = {
		name = 'Vortex',
		damage = 1.2,
		speed = 2.25,
		force = 2.5,
		scatter = 1.25,
		num = 1.3,
		scatterAdd = Vector(0.01, 0.01, 0),
		quality = 6,
		order = 100
	},

	heavy = {
		name = 'Heavy',
		damage = 1.3,
		speed = 0.8,
		force = 4,
		scatter = 1.3,
		quality = 2,
		order = 34
	},

	unstoppable = {
		name = 'Unstoppable',
		damage = 1.85,
		speed = 1,
		force = 1,
		clip = 1.1,
		quality = 4,
		order = 40
	},

	tearing = {
		name = 'Tearing',
		damage = 1.75,
		speed = 1.2,
		force = 2,
		clip = 1.1,
		num = 1.1,
		quality = 4,
		order = 40
	},

	matter = {
		name = '3D Printed',
		damage = 1.5,
		speed = 1.2,
		force = 1.2,
		quality = 2,
		order = 20
	},

	holding = {
		name = 'Holding',
		damage = 1,
		speed = 1,
		force = 1,
		clip = 2,
		num = 1.3,
		quality = 4,
		order = 40
	},

	subspace = {
		name = 'Subspace holding',
		damage = 1,
		speed = 0.8,
		force = 4,
		clip = 3,
		num = 1.35,
		quality = 6,
		order = 100
	},

	penetrated = {
		name = 'Penetrated',
		damage = 0.9,
		speed = 0.65,
		force = 1,
		clip = 0.6,
		num = 0.8,
		quality = -3,
		order = 0
	},

	cursed = {
		name = 'Cursed',
		damage = 0.65,
		speed = 0.6,
		force = 0,
		clip = 0.75,
		num = 0.7,
		quality = -4,
		order = 20
	},

	crumpled = {
		name = 'Crumpled',
		damage = 0.9,
		speed = 0.5,
		force = 1.4,
		clip = 0.6,
		num = 0.9,
		scatter = 1.3,
		scatterAdd = Vector(0.01, 0.01, 0),
		quality = -4,
		order = 40
	},

	enchanted = {
		name = 'Enchanted',
		damage = 1.4,
		speed = 1.2,
		force = 3.25,
		clip = 1.4,
		num = 1.25,
		quality = 5,
		order = 70
	},

	scattering = {
		name = 'Scattering',
		damage = 1.1,
		speed = 0.9,
		force = 2,
		quality = 3,
		numAdd = 2,
		num = 1.3,
		order = 40
	},

	accurate = {
		name = 'Accurate',
		damage = 1.3,
		speed = 0.8,
		force = 4,
		scatter = 0.4,
		num = 0.8,
		quality = 4,
		order = 60
	},

	sniper = {
		name = 'Snipered',
		damage = 1.4,
		speed = 0.7,
		force = 10,
		scatter = 0.1,
		num = 0.65,
		quality = 5,
		order = 23
	},

	deranged = {
		name = 'Deranged',
		damage = 0.9,
		speed = 1.25,
		force = 1.5,
		scatter = 1.4,
		scatterAdd = Vector(0.02, 0.02, 0),
		quality = -3,
		order = 43
	},

	inept = {
		name = 'Inept',
		damage = 0.9,
		speed = 0.9,
		force = 0.8,
		scatter = 1.3,
		scatterAdd = Vector(0.005, 0.005, 0),
		quality = -4,
		order = 64
	},

	ignorant = {
		name = 'Ignorant',
		damage = 1.1,
		speed = 0.7,
		force = 2,
		scatter = 1.5,
		num = 0.9,
		scatterAdd = Vector(0.015, 0.015, 0),
		quality = -4,
		order = 66
	},

	awkward = {
		name = 'Awkward',
		damage = 0.9,
		speed = 0.75,
		force = 4,
		scatter = 1.1,
		num = 0.9,
		quality = -3,
		order = 56
	},

	frenzying = {
		name = 'Frenzying',
		damage = 0.65,
		speed = 1.25,
		force = 0.5,
		clip = 1.25,
		num = 1.1,
		quality = 2,
		order = 29
	},

	wild = {
		name = 'Wild',
		damage = 1,
		speed = 1.2,
		force = 1,
		num = 1.1,
		quality = 2,
		order = 29
	},

	rash = {
		name = 'Rash',
		damage = 0.9,
		speed = 1.3,
		force = 1,
		scatter = 1.1,
		quality = 3,
		order = 48
	},

	violent = {
		name = 'Violent',
		damage = 3,
		speed = 0.5,
		force = 12,
		scatter = 0.8,
		quality = 5,
		order = 100
	},

	precise = {
		name = 'Precise',
		damage = 1.2,
		speed = 0.8,
		force = 1.25,
		scatter = 0.5,
		quality = 3,
		order = 72
	},

	lucky = {
		name = 'Lucky',
		damage = 1.3,
		speed = 1.1,
		force = 0.75,
		scatter = 0.35,
		num = 1.2,
		quality = 4,
		order = 72
	},

	adept = {
		name = 'Adept',
		damage = 1.1,
		speed = 1.1,
		force = 0.9,
		quality = 1,
		order = 21
	},

	angry = {
		name = 'Angry',
		damage = 1.2,
		speed = 1.1,
		force = 1.8,
		clip = 0.85,
		quality = 3,
		order = 78
	},

	factory = {
		name = 'F.A.C.T.O.R.Y',
		damage = 1.75,
		speed = 1.4,
		force = 0.1,
		clip = 1.5,
		num = 1.3,
		quality = 6,
		order = 100
	},

	incredible = {
		name = 'Incredible',
		damage = 1.4,
		speed = 1.9,
		force = 0.1,
		clip = 1.25,
		quality = 5,
		order = 100
	},

	scp = {
		name = 'SCP-Like',
		damage = 2.1,
		speed = 1.25,
		force = 1.4,
		clip = 0.8,
		num = 1.1,
		quality = 7,
		order = 100
	},

	tscp = {
		name = 'True SCP',
		damage = 1.95,
		speed = 1.85,
		force = 4,
		clip = 1.25,
		num = 1.25,
		quality = 8,
		order = 120
	},

	abnormal = {
		name = 'Abnormal',
		damage = 1.7,
		speed = 2,
		force = 3,
		clip = 0.95,
		num = 1.25,
		quality = 6,
		order = 100
	},

	carton = {
		name = 'Toy',
		damage = 0.4,
		speed = 0.8,
		force = 0.1,
		clip = 0.75,
		num = 0.9,
		scatter = 1.4,
		quality = -6,
		order = -30
	},

	hurtful = {
		name = 'Hurtful',
		damage = 1.2,
		speed = 1,
		force = 1,
		scatter = 0.9,
		num = 0.9,
		quality = 1,
		order = 10
	},
}
