
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
import DMapEntityPointer from DMaps

SHOULD_DRAW = DMaps.ClientsideOption('draw_players', '1', 'Draw players on map')

surface.CreateFont('DMaps.PlayerInfoFont', {
	font: 'Roboto',
	size: 48
	weight: 500
})

HU_IN_METER = 40

class AppenableString
	new: (str = '') =>
		@str = str
	
	GetString: => @str
	
	append: (str = '') =>
		@str ..= '\n' .. str
	
	add: (...) => @append(...)
	Append: (...) => @append(...)
	Add: (...) => @append(...)
	Concat: (...) => @append(...)
	concat: (...) => @append(...)

class DMapPlayerPointer extends DMapEntityPointer
	@FONT = 'DMaps.PlayerInfoFont'
	@BACKGROUND_COLOR = Color(0, 0, 0, 150)
	@BACKGROUND_SHIFT = 4
	@UP_VECTOR = Vector(0, 0, 4000)
	@MAX_DELTA_HEIGHT = 600
	@START_FADE_HEIGHT = 200
	@FADE_VALUE_HEIGHT = 400
	@FADE_VALUE_HEIGHT_DIV = 200
	@TRIGGER_FADE_DIST = 800
	
	@__type = 'player'
	
	new: (ply = NULL, filter = DMaps.GetPlayerFilter()) =>
		@filter = filter(ply, @)
		super(ply)
		@playerName = '%PLAYERNAME%'
		
		@hp = 100
		@armor = 0
		@maxhp = 100
		@draw = true
		
		@color = Color(50, 50, 50)
		@teamID = 0
		@teamName = '%PLAYERTEAM%'

	SetEntity: (ply) =>
		super(ply)
		@filter\SetPlayer(ply)
	
	ShouldDraw: => @draw and SHOULD_DRAW\GetBool()

	GetRenderPriority: => 100
	
	CalcPlayerData: (map) =>
		ply = @entity
		
		ang = ply\EyeAngles!
		@playerName = ply\Nick()
		@teamID = ply\Team!
		@color = team.GetColor(@teamID)
		@teamName = team.GetName(@teamID)
		
		@hp = ply\Health!
		@armor = ply\Armor!
		@maxhp = ply\GetMaxHealth!
		
		@pitch = ang.p
		@yaw = -ang.y
		@roll = ang.r
		
	Think: (map) =>
		@CURRENT_MAP = map
		super(map)
		
		if not IsValid(@entity) return
		@CalcPlayerData(map)
		@draw = @filter\Filter(map)
	
	GetPlayerInfo: =>
		text = AppenableString("#{@playerName}
Team: #{@teamName}
HP: #{@hp}/#{@maxhp}
Armor: #{@armor}")
		hook.Run('DMaps.AddPlayerInfo', @, AppenableString)
		
		newStr = text\GetString!
		delta = @GetDeltaHeight!
		
		if delta > 100
			newStr ..= "\n#{math.floor(delta / HU_IN_METER * 10) / 10} meters higher"
		elseif delta < -100
			newStr ..= "\n#{math.floor(-delta / HU_IN_METER * 10) / 10} meters lower"
		
		return newStr
	
	DrawPlayerInfo: (map, x = 0, y = 0, alpha = 1) =>
		y += 90
		surface.SetFont(@@FONT)
		
		text = @GetPlayerInfo!
		w, h = surface.GetTextSize(text)
		
		surface.SetDrawColor(@@BACKGROUND_COLOR.r, @@BACKGROUND_COLOR.g, @@BACKGROUND_COLOR.b, @@BACKGROUND_COLOR.a * alpha)
		surface.DrawRect(x - @@BACKGROUND_SHIFT - w / 2, y - @@BACKGROUND_SHIFT, w + @@BACKGROUND_SHIFT * 2, h + @@BACKGROUND_SHIFT * 2)
		draw.DrawText(text, @@FONT, x, y, Color(@@TEXT_COLOR.r, @@TEXT_COLOR.g, @@TEXT_COLOR.b, @@TEXT_COLOR.a * alpha), TEXT_ALIGN_CENTER)
	
	GetDeltaHeight: => @z - @CURRENT_MAP\GetZ!
	
	Draw: (map) =>
		@CURRENT_MAP = map
		
		trig = @@generateTriangle(@DRAW_X, @DRAW_Y, @yaw, 40, 50, 130)
		
		newAlpha = 1
		delta = @z - map\GetZ!
		deltaAbs = math.abs(delta)
		
		if deltaAbs > @@MAX_DELTA_HEIGHT
			return
		elseif deltaAbs > @@START_FADE_HEIGHT
			newAlpha = math.Clamp((@@FADE_VALUE_HEIGHT - deltaAbs) / @@FADE_VALUE_HEIGHT_DIV, 0.2, 1)
		
		surface.SetDrawColor(@color.r, @color.g, @color.b, @color.a * newAlpha)
		surface.DrawPoly(trig)
		
		x, y = @DRAW_X, @DRAW_Y
		@DrawPlayerInfo(map, x, y, newAlpha)
		
		@CURRENT_MAP = nil

DMaps.DMapPlayerPointer = DMapPlayerPointer
return DMapPlayerPointer
