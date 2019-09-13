
-- Copyright (C) 2019 DBotThePony

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
-- of the Software, and to permit persons to whom the Software is furnished to do so,
-- subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all copies
-- or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
-- INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
-- PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
-- FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
-- DEALINGS IN THE SOFTWARE.

import MCDeaths, math, DLib, type from _G
import DMG_ATTACK, DMG_ANY from MCDeaths

class MCDeaths.StrategySimple extends MCDeaths.StrategyBase
	@COMPONENT_NAME = 'whut'

	new: (tracker) =>
		super(tracker)
		@dmgLastAttack = tracker\Last()

	GetText: =>
		component = {@GetComponent(@dmgLastAttack)}
		componentType = table.remove(component, 1)

		return 'attack.mcdeaths.full.generic.' .. componentType .. '.' .. @@COMPONENT_NAME, unpack(component, 1, #component)

class MCDeaths.StrategyShot extends MCDeaths.StrategySimple
	@TESTER = MCDeaths.PredicateTester({
		MCDeaths.BasicPredicate(DMG_BULLET\bor(DMG_BUCKSHOT))
	}, false)

	@COMPONENT_NAME = 'shot'

class MCDeaths.StrategySlash extends MCDeaths.StrategySimple
	@TESTER = MCDeaths.PredicateTester({
		MCDeaths.BasicPredicate(DMG_SLASH)
	}, false)

	@COMPONENT_NAME = 'slash'

class MCDeaths.StrategyCrush extends MCDeaths.StrategySimple
	@TESTER = MCDeaths.PredicateTester({
		MCDeaths.BasicPredicate(DMG_CRUSH)
	}, false)

	@COMPONENT_NAME = 'crush'

class MCDeaths.StrategyPoisoned extends MCDeaths.StrategySimple
	@TESTER = MCDeaths.PredicateTester({
		MCDeaths.BasicPredicate(DMG_POISON)
	}, false)

	@COMPONENT_NAME = 'poisoned'

class MCDeaths.StrategyVehicle extends MCDeaths.StrategySimple
	@TESTER = MCDeaths.PredicateTester({
		MCDeaths.BasicPredicate(DMG_VEHICLE)
	}, false)

	@COMPONENT_NAME = 'vehicle'

class MCDeaths.StrategyClub extends MCDeaths.StrategySimple
	@TESTER = MCDeaths.PredicateTester({
		MCDeaths.BasicPredicate(DMG_CLUB)
	}, false)

	@COMPONENT_NAME = 'club'

class MCDeaths.StrategyElectric extends MCDeaths.StrategySimple
	@TESTER = MCDeaths.PredicateTester({
		MCDeaths.BasicPredicate(DMG_SHOCK)
	}, false)

	@COMPONENT_NAME = 'electric'

class MCDeaths.StrategySonic extends MCDeaths.StrategySimple
	@TESTER = MCDeaths.PredicateTester({
		MCDeaths.BasicPredicate(DMG_SONIC)
	}, false)

	@COMPONENT_NAME = 'sonic'

class MCDeaths.StrategyAcid extends MCDeaths.StrategySimple
	@TESTER = MCDeaths.PredicateTester({
		MCDeaths.BasicPredicate(DMG_ACID)
	}, false)

	@COMPONENT_NAME = 'acid'

class MCDeaths.StrategyPhysgun extends MCDeaths.StrategySimple
	@TESTER = MCDeaths.PredicateTester({
		MCDeaths.BasicPredicate(DMG_PHYSGUN)
	}, false)

	@COMPONENT_NAME = 'physgun'

class MCDeaths.StrategyPlasma extends MCDeaths.StrategySimple
	@TESTER = MCDeaths.PredicateTester({
		MCDeaths.BasicPredicate(DMG_PLASMA)
	}, false)

	@COMPONENT_NAME = 'plasma'

class MCDeaths.StrategyAirboat extends MCDeaths.StrategySimple
	@TESTER = MCDeaths.PredicateTester({
		MCDeaths.BasicPredicate(DMG_AIRBOAT\bor(DMG_SNIPER))
	}, false)

	@COMPONENT_NAME = 'airboat'

class MCDeaths.StrategyDissolve extends MCDeaths.StrategySimple
	@TESTER = MCDeaths.PredicateTester({
		MCDeaths.BasicPredicate(DMG_DISSOLVE)
	}, false)

	@COMPONENT_NAME = 'dissolve'

class MCDeaths.StrategyDrown extends MCDeaths.StrategySimple
	@TESTER = MCDeaths.PredicateTester({
		MCDeaths.BasicPredicate(DMG_DROWN)
	}, false)

	@COMPONENT_NAME = 'drown'

class MCDeaths.StrategyParalyze extends MCDeaths.StrategySimple
	@TESTER = MCDeaths.PredicateTester({
		MCDeaths.BasicPredicate(DMG_PARALYZE)
	}, false)

	@COMPONENT_NAME = 'paralyze'

class MCDeaths.StrategyNervegas extends MCDeaths.StrategySimple
	@TESTER = MCDeaths.PredicateTester({
		MCDeaths.BasicPredicate(DMG_NERVEGAS)
	}, false)

	@COMPONENT_NAME = 'nervegas'

class MCDeaths.StrategyRadiation extends MCDeaths.StrategySimple
	@TESTER = MCDeaths.PredicateTester({
		MCDeaths.BasicPredicate(DMG_RADIATION)
	}, false)

	@COMPONENT_NAME = 'radiation'
