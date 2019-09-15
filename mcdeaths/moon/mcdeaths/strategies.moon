
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

import MCDeaths, math, DLib from _G
import DMG_ATTACK, DMG_ANY from MCDeaths

class MCDeaths.StrategyBase
	@Test = (tracker) => @TESTER and @TESTER\Test(tracker) or false

	new: (tracker) =>
		@tracker = tracker
		@ent = tracker.ent

	GetText: => 'attack.mcdeaths.full.generic.died', @ent\GetPrintNameDLib(true)

	GetComponent: (dmginfo, last = false) =>
		usePlain = not IsValid(dmginfo\GetAttacker())

		if not usePlain and not (dmginfo\GetAttacker()\IsPlayer() or dmginfo\GetAttacker()\IsNPC() or type(dmginfo\GetAttacker()) == 'NextBot') or dmginfo\GetAttacker() == @ent
			usePlain = true

		if usePlain
			return 'plain', @ent\GetPrintNameDLib(true) if not last
			return 'plain'

		local wepname

		if dmginfo\GetInflictor()\IsWeapon()
			wepname = dmginfo\GetInflictor()\GetPrintNameDLib(true)
		elseif dmginfo\GetInflictor() == dmginfo\GetAttacker() and dmginfo\GetAttacker().GetActiveWeapon and IsValid(dmginfo\GetAttacker()\GetActiveWeapon()) and dmginfo\GetAttacker()\GetActiveWeapon() ~= dmginfo\GetAttacker()
			wepname = dmginfo\GetAttacker()\GetActiveWeapon()\GetPrintNameDLib(true)

		if wepname
			return 'using', @ent\GetPrintNameDLib(true), dmginfo\GetAttacker()\GetPrintNameDLib(true), wepname if not last
			return 'using', dmginfo\GetAttacker()\GetPrintNameDLib(true), wepname
		else
			return 'by', @ent\GetPrintNameDLib(true), dmginfo\GetAttacker()\GetPrintNameDLib(true) if not last
			return 'by', dmginfo\GetAttacker()\GetPrintNameDLib(true)

	@GetPushReasonComponent: (dmg) =>
		switch dmg
			when DMG_GENERIC, true
				return 'attack.mcdeaths.component.fall.generic'
			when DMG_CRUSH
				return 'attack.mcdeaths.component.fall.prop'
			when DMG_BULLET, DMG_BUCKSHOT
				return 'attack.mcdeaths.component.fall.shot'
			when DMG_SLASH
				return 'attack.mcdeaths.component.fall.slash'
			when DMG_VEHICLE
				return 'attack.mcdeaths.component.fall.vehicle'
			when DMG_PHYSGUN
				return 'attack.mcdeaths.component.fall.physgun'
			when DMG_BLAST
				return 'attack.mcdeaths.component.fall.blast'
			when DMG_CLUB
				return 'attack.mcdeaths.component.fall.club'
			when DMG_SHOCK
				return 'attack.mcdeaths.component.fall.shock'
			when DMG_SONIC
				return 'attack.mcdeaths.component.fall.sonic'

		if type(dmg) == 'number'
			return 'attack.mcdeaths.component.fall.prop' if dmg\band(DMG_CRUSH) ~= 0
			return 'attack.mcdeaths.component.fall.shot' if dmg\band(DMG_BULLET\bor(DMG_BUCKSHOT)) ~= 0
			return 'attack.mcdeaths.component.fall.vehicle' if dmg\band(DMG_VEHICLE) ~= 0
			return 'attack.mcdeaths.component.fall.physgun' if dmg\band(DMG_PHYSGUN) ~= 0
			return 'attack.mcdeaths.component.fall.club' if dmg\band(DMG_CLUB) ~= 0
			return 'attack.mcdeaths.component.fall.slash' if dmg\band(DMG_SLASH) ~= 0

		return 'attack.mcdeaths.component.fall.generic'

	@DAMAGE_PRIORITIES = {
		DMG_BULLET
		DMG_SLASH\bor(DMG_CLUB)
		DMG_CRUSH
		DMG_VEHICLE\bor(DMG_PHYSGUN)
	}

	FindPushDamageFrom: (index = 0) =>
		max = -1
		result = false
		i = 0

		for i2, entry in @tracker\LastToFirst(index)
			for priority = max\max(1) + 1, #@@DAMAGE_PRIORITIES
				if entry\GetDamageType()\band(@@DAMAGE_PRIORITIES[priority]) ~= 0
					result = entry
					max = priority
					i = i2
					break if max == #@@DAMAGE_PRIORITIES

		return result, i

	GetComponentPush: (dmginfo) =>
		usePlain = not IsValid(dmginfo\GetAttacker())

		if not usePlain and not (dmginfo\GetAttacker()\IsPlayer() or dmginfo\GetAttacker()\IsNPC() or type(dmginfo\GetAttacker()) == 'NextBot')
			usePlain = true

		if usePlain
			return 'plain', @@GetPushReasonComponent(dmginfo\GetDamageType())

		local wepname

		if dmginfo\GetInflictor()\IsWeapon()
			wepname = dmginfo\GetInflictor()\GetPrintNameDLib(true)
		elseif dmginfo\GetInflictor() == dmginfo\GetAttacker() and dmginfo\GetAttacker().GetActiveWeapon and IsValid(dmginfo\GetAttacker()\GetActiveWeapon()) and dmginfo\GetAttacker()\GetActiveWeapon() ~= dmginfo\GetAttacker()
			wepname = dmginfo\GetAttacker()\GetActiveWeapon()\GetPrintNameDLib(true)

		if wepname
			return 'using', @@GetPushReasonComponent(dmginfo\GetDamageType()), dmginfo\GetAttacker()\GetPrintNameDLib(true), wepname
		else
			return 'by', @@GetPushReasonComponent(dmginfo\GetDamageType()), dmginfo\GetAttacker()\GetPrintNameDLib(true)

compare = (valueIn, compareIn, strategy) ->
	switch strategy
		when MCDeaths.BasicPredicate.CMP_WEAK
			return valueIn\band(compareIn) ~= 0
		when MCDeaths.BasicPredicate.CMP_EXACT
			return valueIn\band(compareIn) == compareIn

	return false

class MCDeaths.BasicPredicate
	@TEST_SINGLE = 0
	@TEST_ALL = 1
	@TEST_UNTIL = 2

	@CMP_EXACT = 0
	@CMP_WEAK = 1

	new: (dmgtype, strategy = @@CMP_WEAK) =>
		@dmginfo = dmgtype
		@strategy = strategy
		@test_type = @@TEST_SINGLE

	StrategyAll: =>
		@test_type = @@TEST_ALL
		return @

	StrategyUntil: (dmgtype, strategy = @@CMP_WEAK) =>
		@test_type = @@TEST_UNTIL
		@until_dmgtype = dmgtype
		@until_strategy = strategy
		return @

	AtLeastOne: (dmgtype, strategy = @@CMP_WEAK) =>
		@at_least_one = dmgtype
		@at_least_one_strategy = strategy
		return @

	TestValue: (valueIn) => compare(valueIn\GetDamageType(), @dmginfo, @strategy)

	Test: (buff, startFrom) =>
		switch @test_type
			when @@TEST_SINGLE
				return false, 0 if not buff[startFrom]
				return @TestValue(buff[startFrom]), 1

			when @@TEST_ALL
				for i = startFrom, #buff
					if not @TestValue(buff[i])
						return false, #buff - i + 1

				if @at_least_one
					hit = false

					for i = startFrom, #buff
						if compare(buff[i]\GetDamageType(), @at_least_one, @at_least_one_strategy)
							hit = true
							break

					return false if not hit

				return startFrom <= #buff, #buff - startFrom + 1

			when @@TEST_UNTIL
				hit = false

				for i = startFrom, #buff
					if not @TestValue(buff[i])
						switch @until_strategy
							when @@CMP_WEAK
								if buff[i]\GetDamageType()\band(@until_dmgtype) ~= 0
									return hit, i - startFrom

							when @@CMP_EXACT
								if buff[i]\GetDamageType()\band(@until_dmgtype) == @until_dmgtype
									return hit, i - startFrom
					else
						hit = true

				if @at_least_one
					hit2 = false

					for i = startFrom, #buff
						if compare(buff[i]\GetDamageType(), @at_least_one, @at_least_one_strategy)
							hit2 = true
							break

					return false if not hit2

				return hit, #buff - startFrom + 1

class MCDeaths.PredicateTester
	new: (predicates, firstIn = true) =>
		@predicates = predicates
		@firstIn = firstIn

	Test: (tracker) =>
		entries = tracker\GetEntries()
		return false if #entries == 0
		return false if not @firstIn and #entries < #@predicates

		predicate = 1
		local lastTest, index

		if @firstIn
			lastTest, index = @predicates[predicate]\Test(entries, 1)
		else
			lastTest, index = @predicates[predicate]\Test(entries, #entries - #@predicates + 1)
			return false if not lastTest
			index += #entries - #@predicates

		while lastTest and predicate < #@predicates
			index += 1
			predicate += 1
			ourTest, ourIndex = @predicates[predicate]\Test(entries, index)
			lastTest = ourTest
			break if not ourTest
			index += ourIndex

		return lastTest

include 'mcdeaths/strategies/plain.lua'
include 'mcdeaths/strategies/fall.lua'
include 'mcdeaths/strategies/advanced.lua'
include 'mcdeaths/strategies/finishoff.lua'

class MCDeaths.StrategyUnknown extends MCDeaths.StrategyBase
	@Test = => true

	GetText: =>
		component = {@GetComponent(@dmgLastAttack)}
		componentType = table.remove(component, 1)

		return 'attack.mcdeaths.full.generic.' .. componentType .. '.died', unpack(component, 1, #component)

MCDeaths.Strategies = {
	MCDeaths.StrategyDirect
	MCDeaths.StrategyFellOut

	MCDeaths.StrategyFellAndFinishedOff
	MCDeaths.StrategyFellAfterAttack

	MCDeaths.StrategyPropAndFinishedOff

	MCDeaths.StrategySlowburn
	MCDeaths.StrategyBurnt

	MCDeaths.StrategyVehicleAndFinishedOff
	MCDeaths.StrategyExplosion

	MCDeaths.StrategyExplosion
	MCDeaths.StrategyLaserAndFinishedOff
	MCDeaths.StrategyLaserAfterAttack
	MCDeaths.StrategyAcidAfterAttack

	MCDeaths.StrategyFell
	MCDeaths.StrategyDissolve
	MCDeaths.StrategyShot
	MCDeaths.StrategySlash
	MCDeaths.StrategyCrush
	MCDeaths.StrategyPoisoned
	MCDeaths.StrategyVehicle
	MCDeaths.StrategyClub
	MCDeaths.StrategyElectric
	MCDeaths.StrategySonic
	MCDeaths.StrategyDrown
	MCDeaths.StrategyParalyze
	MCDeaths.StrategyNervegas
	MCDeaths.StrategyLaserBasic
	MCDeaths.StrategyAcid
	MCDeaths.StrategyPhysgun
	MCDeaths.StrategyPlasma
	MCDeaths.StrategyRadiation
	MCDeaths.StrategyAirboat

	MCDeaths.StrategyUnknown
}
