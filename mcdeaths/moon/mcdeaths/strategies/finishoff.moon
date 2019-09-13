
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

class MCDeaths.StrategyLaserBasic extends MCDeaths.StrategySimple
	@TESTER = MCDeaths.PredicateTester({
		MCDeaths.BasicPredicate(DMG_ENERGYBEAM)
	}, false)

	@COMPONENT_NAME = 'laser'

class MCDeaths.StrategyLaserAfterAttack extends MCDeaths.StrategyFellAfterAttack
	@TESTER = MCDeaths.PredicateTester({
		MCDeaths.BasicPredicate(DMG_ANY - DMG_ENERGYBEAM)\StrategyUntil(DMG_ENERGYBEAM)
		MCDeaths.BasicPredicate(DMG_ENERGYBEAM, MCDeaths.BasicPredicate.CMP_EXACT)\StrategyAll()
	}, false)

	@__component = 'laser'
	@__use_small = false
	@__with_attacker = true

class MCDeaths.StrategyLaserAndFinishedOff extends MCDeaths.StrategyFellAndFinishedOff
	@TESTER = MCDeaths.PredicateTester({
		MCDeaths.BasicPredicate(DMG_ANY - DMG_ENERGYBEAM)\StrategyUntil(DMG_ENERGYBEAM)
		MCDeaths.BasicPredicate(DMG_ENERGYBEAM, MCDeaths.BasicPredicate.CMP_EXACT)\StrategyAll()
		MCDeaths.BasicPredicate(DMG_ANY - DMG_ENERGYBEAM)\StrategyAll()\AtLeastOne(DMG_ANY - DMG_ENERGYBEAM)
	}, false)

	@__component = 'laser'
	@__use_small = false
	@__with_attacker = true
	@__dmgtype = DMG_ENERGYBEAM

class MCDeaths.StrategyPropAndFinishedOff extends MCDeaths.StrategyBase
	@TESTER = MCDeaths.PredicateTester({
		MCDeaths.BasicPredicate(DMG_CRUSH, MCDeaths.BasicPredicate.CMP_EXACT)\StrategyUntil(DMG_ANY)
		MCDeaths.BasicPredicate(DMG_ANY)\StrategyAll()\AtLeastOne(DMG_ANY - DMG_CRUSH)
	})

	new: (tracker) =>
		super(tracker)
		@dmgFatal = tracker\Last(1)
		@dmgFinish = tracker\Last()

		for i, entry in tracker\LastToFirst(1)
			if entry\GetDamageType()\band(DMG_CRUSH) ~= 0
				@dmgFatal = entry
				break

	GetText: =>
		component1 = {@GetComponent(@dmgFatal)}
		component2 = {@GetComponent(@dmgFinish, true)}
		name1 = table.remove(component1, 1)
		name2 = table.remove(component2, 1)

		rebuild = {'attack.mcdeaths.component.crush_finished.' .. name1 .. '_' .. name2}

		table.append(rebuild, component1)
		table.append(rebuild, component2)
		return unpack(rebuild, 1, #rebuild)

class MCDeaths.StrategyDirect extends MCDeaths.StrategySimple
	@TESTER = MCDeaths.PredicateTester({
		MCDeaths.BasicPredicate(DMG_DIRECT)
	}, false)

	@COMPONENT_NAME = 'outofworld'

	new: (tracker) =>
		super(tracker)
		@lastFigher, @lastFigherIndex = tracker\FirstNonSelfFigher(1)

	GetText: =>
		if not @lastFigher
			return super()

		component1 = {@GetComponentPush(@lastFigher)}
		component2 = {@GetComponent(@dmgLastAttack, true)}

		name1 = table.remove(component1, 1)
		name2 = table.remove(component2, 1)

		rebuild = {'attack.mcdeaths.component.outofworld.' .. name1 .. '_' .. name2, @ent\GetPrintNameDLib(true)}

		table.append(rebuild, component1)
		table.append(rebuild, component2)
		return unpack(rebuild, 1, #rebuild)