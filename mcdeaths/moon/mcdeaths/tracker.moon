
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

import DLib, luatype, table, MCDeaths, CurTimeL from _G

DMGINFO_TTL = CreateConVar('sv_mcdeaths_ttl', '10', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Time in seconds for which takedamageinfo is considered valid (and affect death message)')

class MCDeaths.CombatTracker
	new: (track) =>
		@ent = track
		@entries = {}
		@nextclear = math.huge

	Track: (dmg) =>
		return if dmg\GetDamage() <= 0
		dmg = DLib.LTakeDamageInfo(dmg) if luatype(dmg) == 'CTakeDamageInfo'
		dmg.__mc_stamp = CurTimeL()
		dmg.__mc_stampe = CurTimeL() + DMGINFO_TTL\GetFloat(10)
		dmg.__mc_index = table.insert(@entries, dmg)
		@nextclear = @nextclear\min(dmg.__mc_stampe)
		dmg.__mc_hp, dmg.__mc_mhp = @ent\Health(), @ent\GetMaxHealth()
		@Clear()

	ForceClear: =>
		return false if #@entries == 0
		@entries = {}
		@nextclear = math.huge
		@strategy_cache = nil
		return true

	Clear: =>
		ctime = CurTimeL()
		return if ctime < @nextclear
		@entries = [entry for entry in *@entries when entry.__mc_stampe > ctime]
		@strategy_cache = nil

		if #@entries == 0
			@nextclear = math.huge
			return

		@nextclear = @entries[1].__mc_stampe

	GetEntries: => @entries
	Last: (index = 0) => @entries[#@entries - index] or false

	LastToFirst: (index = 0) =>
		current = #@entries - index

		return ->
			value = @entries[current]
			current -= 1
			return current, value if value ~= nil

	FirstFigher: (index = 0) =>
		for i, entry in @LastToFirst(index)
			if attacker = entry\GetAttacker()
				if IsValid(attacker) and (attacker\IsNPC() or attacker\IsPlayer() or type(attacker) == 'NextBot')
					return entry, i

		return false

	FirstNonSelfFigher: (index = 0) =>
		for i, entry in @LastToFirst(index)
			if attacker = entry\GetAttacker()
				if attacker ~= @ent and IsValid(attacker) and (attacker\IsNPC() or attacker\IsPlayer() or type(attacker) == 'NextBot')
					return entry, i

		return false

	FindBefore: (timeBefore) => [@entries[i] for i = #@entries, 1, -1 when @entries[i].__mc_stamp < timeBefore]
	FindBeforeType: (timeBefore, dmgType) => [@entries[i] for i = #@entries, 1, -1 when @entries[i].__mc_stamp < timeBefore and @entries[i]\IsDamageType(dmgType)]
	FindBeforeTypeExact: (timeBefore, dmgType) => [@entries[i] for i = #@entries, 1, -1 when @entries[i].__mc_stamp < timeBefore and @entries[i]\GetDamageType() == dmgType]

	FindType: (dmgType) => [@entries[i] for i = #@entries, 1, -1 when @entries[i]\IsDamageType(dmgType)]
	FindTypeExact: (dmgType) => [@entries[i] for i = #@entries, 1, -1 when @entries[i]\GetDamageType() == dmgType]

	PlanStrategy: =>
		return MCDeaths.StrategyUnknown if #@entries == 0

		for entry in *MCDeaths.Strategies
			if entry\Test(@)
				return entry

		return MCDeaths.StrategyUnknown

	ComputeStrategy: =>
		plan = @PlanStrategy()
		return false if not plan
		@strategy_cache = plan(@)

		return @strategy_cache

	GetStrategy: =>
		return @strategy_cache if @strategy_cache
		return @ComputeStrategy()
