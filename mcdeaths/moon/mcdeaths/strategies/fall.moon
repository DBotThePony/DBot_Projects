
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

class MCDeaths.StrategyFell extends MCDeaths.StrategyBase
	@TESTER = MCDeaths.PredicateTester({
		MCDeaths.BasicPredicate(DMG_FALL)\StrategyAll()
	})

	new: (tracker) =>
		super(tracker)
		@dmgFatal = tracker\Last()

	GetText: =>
		small = @DetermineLimits()

		if @dmgFatal\GetDamage() <= small
			return 'attack.mcdeaths.full.fall.small', @ent\GetPrintNameDLib(true)
		else
			return 'attack.mcdeaths.full.fall.regular', @ent\GetPrintNameDLib(true)

	DetermineLimits: =>
		return @small, @medium, @large if @small
		return false if not @ent\IsPlayer()
		points = {}

		table.insert(points, hook.Run('GetFallDamage', @ent, speed) or 0) for speed = 100, 2000, 100

		@small = math.tbezier(0.3, points)\round()
		@medium = math.tbezier(0.55, points)\round()
		@large = math.tbezier(0.8, points)\round()
		return @small, @medium, @large

class MCDeaths.StrategyFellOut extends MCDeaths.StrategyBase
	@Test = (tracker) =>
		last = tracker\Last()
		return false if not last\IsFallDamage() and last\GetDamageType() ~= 0
		return last\GetAttacker()\IsValid() and last\GetAttacker()\GetClass() == 'trigger_hurt'

	GetText: => 'attack.mcdeaths.full.generic.plain.outofworld', @ent\GetPrintNameDLib(true)

class MCDeaths.StrategyFellAfterAttack extends MCDeaths.StrategyFell
	@TESTER = MCDeaths.PredicateTester({
		MCDeaths.BasicPredicate(DMG_ANY - DMG_FALL)\StrategyUntil(DMG_FALL)
		MCDeaths.BasicPredicate(DMG_FALL, MCDeaths.BasicPredicate.CMP_EXACT)\StrategyAll()
	}, false)

	@__component = 'fall'
	@__use_small = true
	@__with_attacker = false

	new: (tracker, search = true) =>
		super(tracker)
		@dmgFatal = tracker\Last()
		@dmgLastAttack = @FindPushDamageFrom(1) or tracker\FirstNonSelfFigher() or tracker\Last(1)

	GetText: =>
		if @@__with_attacker
			component1 = {@GetComponentPush(@dmgLastAttack)}
			component2 = {@GetComponent(@dmgFatal)}
			name1 = table.remove(component1, 1)
			name2 = table.remove(component2, 1)
			issmall = @@__use_small

			if issmall
				small = @DetermineLimits()
				issmall = @dmgFatal\GetDamage() <= small

			rebuild = {'attack.mcdeaths.component.' .. @@__component .. '.' .. name1 .. '_' .. name2 .. '.' .. (issmall and 'small' or 'regular'), @ent\GetPrintNameDLib(true)}

			table.append(rebuild, component1)
			table.append(rebuild, component2)

			return unpack(rebuild, 1, #rebuild)
		else
			component = {@GetComponentPush(@dmgLastAttack)}
			componentType = table.remove(component, 1)
			issmall = @@__use_small

			if issmall
				small = @DetermineLimits()
				issmall = @dmgFatal\GetDamage() <= small

			return 'attack.mcdeaths.component.' .. @@__component .. '.' .. componentType .. '.' .. (issmall and 'small' or 'regular'), @ent\GetPrintNameDLib(true), unpack(component, 1, #component)

class MCDeaths.StrategyFellAndFinishedOff extends MCDeaths.StrategyFellAfterAttack
	@TESTER = MCDeaths.PredicateTester({
		MCDeaths.BasicPredicate(DMG_ANY - DMG_FALL)\StrategyUntil(DMG_FALL)
		MCDeaths.BasicPredicate(DMG_FALL, MCDeaths.BasicPredicate.CMP_EXACT)\StrategyUntil(DMG_ANY)
		MCDeaths.BasicPredicate(DMG_ANY)\StrategyAll()\AtLeastOne(DMG_ANY - DMG_FALL)
	}, false)

	@__component = 'fall_finished'
	@__use_small = false
	@__dmgtype = DMG_FALL

	@GetPushReasonComponent: (dmg) =>
		str = super(dmg)
		return str if str ~= 'attack.mcdeaths.component.fall.vehicle'
		return 'attack.mcdeaths.component.fall.vehicle2'

	new: (tracker) =>
		super(tracker, false)
		@dmgLastAttack = tracker\Last(2)
		@dmgFatal = tracker\Last(1)
		@dmgFinish = tracker\Last()

		searchFrom = 1

		max = -1
		max = priority for priority, dmgtype in ipairs(@@DAMAGE_PRIORITIES) when @dmgLastAttack\GetDamageType()\band(dmgtype) ~= 0
		entries = tracker\GetEntries()

		for i, entry in ipairs(entries)
			if entry\IsDamageType(@@__dmgtype)
				searchFrom = i + 1
				@dmgFatal = entry
				break

			for priority = max\max(1), #@@DAMAGE_PRIORITIES
				if entry\GetDamageType()\band(@@DAMAGE_PRIORITIES[priority]) ~= 0
					@dmgLastAttack = entry
					max = priority

		max = -1
		max = priority for priority, dmgtype in ipairs(@@DAMAGE_PRIORITIES) when @dmgFinish\GetDamageType()\band(dmgtype) ~= 0

		for i = searchFrom, #entries
			entry = entries[i]

			for priority = max\max(1), #@@DAMAGE_PRIORITIES
				if entry\GetDamageType()\band(@@DAMAGE_PRIORITIES[priority]) ~= 0
					@dmgFinish = entry
					max = priority

	GetText: =>
		if @@__with_attacker
			component1 = {@GetComponentPush(@dmgLastAttack)}
			component2 = {@GetComponent(@dmgFatal, true)}
			component3 = {@GetComponent(@dmgFinish, true)}

			name1 = table.remove(component1, 1)
			name2 = table.remove(component2, 1)
			name3 = table.remove(component3, 1)

			rebuild = {'attack.mcdeaths.component.' .. @@__component .. '_finished.' .. name1 .. '_' .. name2 .. '_' .. name3, @ent\GetPrintNameDLib(true)}

			table.append(rebuild, component1)
			table.append(rebuild, component2)
			table.append(rebuild, component3)
			return unpack(rebuild, 1, #rebuild)
		else
			component1 = {@GetComponentPush(@dmgLastAttack)}
			component2 = {@GetComponent(@dmgFinish, true)}

			name1 = table.remove(component1, 1)
			name2 = table.remove(component2, 1)

			rebuild = {'attack.mcdeaths.component.' .. @@__component .. '_finished.' .. name1 .. '_' .. name2, @ent\GetPrintNameDLib(true)}

			table.append(rebuild, component1)
			table.append(rebuild, component2)
			return unpack(rebuild, 1, #rebuild)
