
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

import DMaps from _G

FLAGS = {FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE}

POINTS_ENABLED = CreateConVar('sv_dmaps_players', '1', FLAGS, 'Enable player map arrows')
ENABLE_STREET_CHECK = CreateConVar('sv_dmaps_players_street', '1', FLAGS, 'Sandbox Player Filter: Enable player "is on street" check')
STREET_CHECK_DIST = CreateConVar('sv_dmaps_players_street_dist', '9999', FLAGS, 'Sandbox Player Filter: "is on street" check max draw distance (Hammer units)')
MAX_DELTA = CreateConVar('sv_dmaps_players_max_delta', '600', FLAGS, 'Sandbox Player Filter: Max distance (Hammer units) in Z "height", before hiding player')
START_FADE = CreateConVar('sv_dmaps_players_start_fade', '200', FLAGS, 'Sandbox Player Filter: Distance (Hammer units) in Z "height", before starting player fade')
START_HIDE = CreateConVar('sv_dmaps_players_start_hide', '800', FLAGS, 'Sandbox Player Filter: Distance (Hammer units)')

class PlayerFilterBase
	new: (ply = NULL, waypoint) =>
		@ply = ply
		@waypoint = waypoint
	IsValid: => IsValid(@ply) and IsValid(@waypoint)
	Filter: => false
	SetPlayer: (ply) => @ply = ply
	GetPlayer: => @ply
	GetPos: => @ply\GetPos()
	EyePos: => @ply\EyePos()

DMaps.PlayerFilterBase = PlayerFilterBase

class SandboxPlayerFilter extends PlayerFilterBase
	@UP_VECTOR = Vector(0, 0, 4000)
	@MAX_DELTA_HEIGHT = 600
	@START_FADE_HEIGHT = 200
	@FADE_VALUE_HEIGHT = 400
	@FADE_VALUE_HEIGHT_DIV = 200
	@TRIGGER_FADE_DIST = 800
	@SREET_DISTANCE = 9999
	@CHECK_TRACE = true

	hook.Add 'Think', 'DMaps.SandboxPlayerFilter', ->
		@MAX_DELTA_HEIGHT = MAX_DELTA\GetInt()
		@START_FADE_HEIGHT = START_FADE\GetInt()
		@TRIGGER_FADE_DIST = START_HIDE\GetInt()
		@SREET_DISTANCE = STREET_CHECK_DIST\GetInt()
		@CHECK_TRACE = ENABLE_STREET_CHECK\GetBool()
	
	new: (ply, waypoint) =>
		super(ply, waypoint)
	
	Filter: (map) =>
		return false if not POINTS_ENABLED\GetBool()
		dh = @waypoint\GetDeltaHeight()
		
		if dh > @@MAX_DELTA_HEIGHT or dh < -@@MAX_DELTA_HEIGHT
			return false
		elseif map.abstractSetup
			pos = @waypoint\GetPos()
			dist = map\GetAbstractPos()\Distance(pos)
			if dist > @@TRIGGER_FADE_DIST
				if @@CHECK_TRACE and dist < @@SREET_DISTANCE
					trData = {
						mask: MASK_BLOCKLOS
						filter: ply
						start: pos
						endpos: pos + @@UP_VECTOR
					}
					
					tr = util.TraceLine(trData)
					
					if not tr.Hit or tr.HitSky
						return true
					else
						return false
				else
					return false
			else
				return true
		else
			return true

class DarkRPPlayerFilter extends SandboxPlayerFilter
	new: (ply, waypoint) =>
		super(ply, waypoint)
	
	Filter: (map) =>
		return false if @ply.isWanted and @ply\isWanted()
		return false if @ply.isArrested and @ply\isArrested()
		return super(map)

class ZSPlayerFilter extends SandboxPlayerFilter
	new: (ply, waypoint) =>
		super(ply, waypoint)
		@lc = LocalPlayer()
	
	Filter: =>
		if @lc\Team() ~= @ply\Team() return false
		return super()

DMaps.SandboxPlayerFilter = SandboxPlayerFilter
DMaps.DarkRPPlayerFilter = DarkRPPlayerFilter
DMaps.ZSPlayerFilter = ZSPlayerFilter

DMaps.PLAYER_FILTRES = {}
DMaps.RegisterPlayerFilter = (gamemodes = {}, filter = PlayerFilterBase) ->
	gamemodes = {gamemodes} if type(gamemodes) ~= 'table'
	DMaps.PLAYER_FILTRES[g] = filter for g in *gamemodes

DMaps.GetPlayerFilter = (g = engine.ActiveGamemode()) -> DMaps.PLAYER_FILTRES[g\lower()] or PlayerFilterBase

DMaps.RegisterPlayerFilter({'sandbox'}, SandboxPlayerFilter)
DMaps.RegisterPlayerFilter({'darkrp'}, DarkRPPlayerFilter)
DMaps.RegisterPlayerFilter({'base', 'terrortown'}, PlayerFilterBase)
DMaps.RegisterPlayerFilter({'zombiesurvival'}, ZSPlayerFilter) -- example
hook.Run('DMaps.RegisterPlayerFilters', DMaps.RegisterPlayerFilter, PlayerFilterBase)
