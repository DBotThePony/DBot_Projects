
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

class MCDeaths.StrategyBurnt extends MCDeaths.StrategyBase
	@TESTER = MCDeaths.PredicateTester({
		MCDeaths.BasicPredicate(DMG_BURN)
	}, false)

	new: (tracker) =>
		super(tracker)
		@dmgLastAttack = tracker\Last()
		@lastFigher, @lastFigherIndex = tracker\FirstNonSelfFigher(1)

	GetText: =>
		component = {@GetComponent(@dmgLastAttack)}
		componentType = table.remove(component, 1)

		if componentType == 'plain' and @lastFigher
			mclass = @dmgLastAttack\GetAttacker()\GetClass()
			figher = @lastFigher\GetAttacker()

			if (mclass == 'entityflame' or mclass == 'env_entity_igniter') and @dmgLastAttack\GetAttacker()\GetParent() ~= @ent
				if IsValid(figher)
					return 'attack.mcdeaths.full.whilst.assist', @ent\GetPrintNameDLib(true), figher\GetPrintNameDLib(true)
				else
					return 'attack.mcdeaths.full.plain.assist_empty', @ent\GetPrintNameDLib(true)
			else
				if IsValid(figher)
					return 'attack.mcdeaths.full.generic.whilst.flame', @ent\GetPrintNameDLib(true), figher\GetPrintNameDLib(true)
				else
					return 'attack.mcdeaths.full.generic.plain.flame', @ent\GetPrintNameDLib(true)

		elseif componentType == 'plain' and IsValid(@dmgLastAttack\GetAttacker())
			mclass = @dmgLastAttack\GetAttacker()\GetClass()

			if (mclass == 'entityflame' or mclass == 'env_entity_igniter') and @dmgLastAttack\GetAttacker()\GetParent() ~= @ent
				return 'attack.mcdeaths.full.flame.standing', @ent\GetPrintNameDLib(true)

		return 'attack.mcdeaths.full.generic.' .. componentType .. '.flame', unpack(component, 1, #component)

class MCDeaths.StrategySlowburn extends MCDeaths.StrategyBurnt
	@TESTER = MCDeaths.PredicateTester({
		MCDeaths.BasicPredicate(DMG_SLOWBURN)
	}, false)

	new: (tracker) =>
		super(tracker)

	GetText: =>
		component = {@GetComponent(@dmgLastAttack)}
		componentType = table.remove(component, 1)

		if componentType ~= 'plain'
			return super()

		return 'attack.mcdeaths.full.flame.standing', unpack(component, 1, #component)

class MCDeaths.StrategyVehicleAndFinishedOff extends MCDeaths.StrategyBase
	@TESTER = MCDeaths.PredicateTester({
		MCDeaths.BasicPredicate(DMG_VEHICLE, MCDeaths.BasicPredicate.CMP_EXACT)\StrategyUntil(DMG_ANY)
		MCDeaths.BasicPredicate(DMG_ANY)\StrategyAll()\AtLeastOne(DMG_ANY - DMG_VEHICLE)
	}, false)

	new: (tracker) =>
		super(tracker)

		for i, entry in tracker\LastToFirst()
			if not @dmgLast and entry\GetDamageType()\band(DMG_ANY - DMG_VEHICLE) ~= 0
				@dmgLast = entry
				@lastFigher = entry if not @lastFigher and MCDeaths.IsFigher(entry\GetAttacker())
			elseif not @lastFigher and entry\GetDamageType()\band(DMG_ANY - DMG_VEHICLE) ~= 0 and MCDeaths.IsFigher(entry\GetAttacker())
				@lastFigher = entry
			elseif not @dmgVehicle and entry\IsVehicleDamage()
				@dmgVehicle = entry
				break

	GetText: =>
		component1 = {@GetComponent(@dmgVehicle)}
		component2 = {@GetComponent(@dmgLast or @lastFigher)}

		rebuild = {'attack.mcdeaths.component.vehicle_finished.' .. component1[1] .. '_' .. component2[1], @ent\GetPrintNameDLib(true)}
		table.splice(component1, 1, 2)
		table.splice(component2, 1, 2)
		table.append(rebuild, component1)
		table.append(rebuild, component2)
		return unpack(rebuild, 1, #rebuild)

class MCDeaths.StrategyExplosion extends MCDeaths.StrategyBase
	@TESTER = MCDeaths.PredicateTester({
		MCDeaths.BasicPredicate(DMG_BLAST\bor(DMG_MISSILEDEFENSE))
	}, false)

	new: (tracker) =>
		super(tracker)
		@dmgLastAttack = tracker\Last()
		@lastFighter, @lastFighterIndex = tracker\FirstNonSelfFigher(1)

	GetText: =>
		component = {@GetComponent(@dmgLastAttack)}
		componentType = table.remove(component, 1)

		if @dmgLastAttack\GetAttacker() == @ent and @lastFighter and @lastFighter\GetAttacker()\IsValid()
			return 'attack.mcdeaths.full.explosion.assist', @ent\GetPrintNameDLib(true), @lastFighter\GetAttacker()\GetPrintNameDLib(true)

		return 'attack.mcdeaths.full.generic.' .. componentType .. '.explosion', unpack(component, 1, #component)

class MCDeaths.StrategyAcidAfterAttack extends MCDeaths.StrategyFellAfterAttack
	@TESTER = MCDeaths.PredicateTester({
		MCDeaths.BasicPredicate(DMG_ANY - DMG_ACID)\StrategyUntil(DMG_ACID)
		MCDeaths.BasicPredicate(DMG_ACID, MCDeaths.BasicPredicate.CMP_EXACT)\StrategyAll()
	}, false)

	@__component = 'acid'
	@__use_small = false
	@__with_attacker = true
