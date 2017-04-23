
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

POINTS_ENABLED = CreateConVar('sv_dmaps_players', '1', {FCVAR_REPLICATED, FCVAR_ARCHIVE}, 'Enable player map arrows')

class PlayerFilterBase
	new: (ply = NULL, waypoint) =>
		@ply = ply
		@waypoint = waypoint
	IsValid: => IsValid(@ply) and IsValid(@waypoint)
	Filter: => false
	SetPlayer: (ply) => @ply = ply
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
	
	new: (ply, waypoint) =>
		super(ply, waypoint)
	
	Filter: (map) =>
		return false if not POINTS_ENABLED\GetBool()
		dh = @waypoint\GetDeltaHeight()
		
		if dh > @@MAX_DELTA_HEIGHT or dh < -@@MAX_DELTA_HEIGHT
			return false
		elseif map.abstractSetup
			pos = @waypoint\GetPos()
			if map\GetAbstractPos!\Distance(pos) > @@TRIGGER_FADE_DIST
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
				return true
		else
			return true

class ZSPlayerFilter extends SandboxPlayerFilter
	new: (ply, waypoint) =>
		super(ply, waypoint)
		@lc = LocalPlayer()
	
	Filter: =>
		if @lc\Team() ~= @ply\Team() return false
		return super()

DMaps.SandboxPlayerFilter = SandboxPlayerFilter
DMaps.ZSPlayerFilter = ZSPlayerFilter

DMaps.PLAYER_FILTRES = {}
DMaps.RegisterPlayerFilter = (gamemodes = {}, filter = PlayerFilterBase) ->
	gamemodes = {gamemodes} if type(gamemodes) ~= 'table'
	DMaps.PLAYER_FILTRES[g] = filter for g in *gamemodes

DMaps.GetPlayerFilter = (g = engine.ActiveGamemode()) -> DMaps.PLAYER_FILTRES[g\lower()] or PlayerFilterBase

DMaps.RegisterPlayerFilter({'sandbox', 'darkrp'}, SandboxPlayerFilter)
DMaps.RegisterPlayerFilter({'base', 'terrortown'}, PlayerFilterBase)
DMaps.RegisterPlayerFilter({'zombiesurvival'}, ZSPlayerFilter) -- example
hook.Run('DMaps.RegisterPlayerFilters', DMaps.RegisterPlayerFilter, PlayerFilterBase)
