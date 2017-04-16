
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

import DMaps, file, Material, SERVER, CLIENT, ipairs from _G
import surface, draw from _G

DMaps.IconsPrefix = 'dmaps/'
DMaps.IconsPrefixFull = 'materials/dmaps/'

class Icon
	@IconsPrefix = DMaps.IconsPrefix
	@IconsPrefixFull = DMaps.IconsPrefixFull
	@AvaliableBare = {
		'apple'
		'auction_hammer_gavel'
		'award_star_bronze_blue'
		'award_star_bronze_green'
		'award_star_bronze_red'
		'award_star_gold_blue'
		'award_star_gold_green'
		'award_star_gold_red'
		'award_star_silver_blue'
		'award_star_silver_green'
		'ax'
		'bin_closed'
		'box'
		'bug'
		'button_picture'
		'cactus'
		'camera'
		'car'
		'chameleon'
		'chocolate'
		'church'
		'cog'
		'cold'
		'computer'
		'database'
		'door_open'
		'draw_eraser'
		'drive'
		'entity'
		'events'
		'film'
		'flower'
		'folding_fan'
		'hamburger'
		'hammer'
		'hat'
		'ipad'
		'iphone'
		'laptop'
		'mail_yellow'
		'math_functions'
		'medal_bronze_blue'
		'medal_bronze_green'
		'medal_bronze_red'
		'monitor'
		'oil_barrel'
		'pill'
		'point_gold'
		'radiolocator'
		'rainbow'
		'shield'
		'soil_layers'
		'sport_basketball'
		'sport_soccer'
		'system_monitor'
		'theater'
		'transmit'
		'video'
		'wizard'
	}
	
	@GetNetworkID = (iconName) => @IconID[iconName] or 1
	@GetIconName = (netID = 1) => @AvaliableBare[netID] or @AvaliableBare[1]
	
	@FixIcon = (name) =>
		return name if @AvaliableBareMap[name]
		return @AvaliableBare[1]
	
	@DefaultIconName = @AvaliableBare[1]
	@GetIcons = => @AvaliableBare
	@CopyIcons = => [icon for icon in *@AvaliableBare]
	
	@IconID = {icon, i for i, icon in ipairs @AvaliableBare}
	@Avaliable = [icon .. '.png' for icon in *@AvaliableBare]
	@AvaliableFull = [DMaps.IconsPrefix .. icon for icon in *@Avaliable]
	@AvaliableFullFile = [DMaps.IconsPrefixFull .. icon for icon in *@Avaliable]
	
	@AvaliableBareMap = {icon, icon for icon in *@AvaliableBare}
	@AvaliableMap = {icon, icon for icon in *@Avaliable}
	@AvaliableFullMap = {icon, icon for icon in *@AvaliableFull}
	@AvaliableFullFileMap = {icon, icon for icon in *@AvaliableFullFile}
	
	@FILES = {icon, file.Exists(icon, 'GAME') for icon in *@AvaliableFullFile}
	@MATERIALS = {icon, Material(icon) for icon in *@AvaliableFull} if CLIENT
	
	@SIZE_X = 32
	@SIZE_Y = 32
	
	@__type = 'icon'
	
	-- Static data end
	new: (name = @@AvaliableBare[1], forceDrawDefault = false) =>
		@name = name
		@bareName = name
		@valid = false
		@forceDrawDefault = forceDrawDefault
		if not @@AvaliableBareMap[name] return
		
		@ID = @@IconID[name]
		@nameFull = @@AvaliableFull[@ID]
		@file = @@AvaliableFullFile[@ID]
		@material = @@MATERIALS[@nameFull] if CLIENT
	
	@GENERATE_POLY = (x = 0, y = 0, sizeX = 30, sizeY = 30) =>
		output = {
			{x: x, y: y - sizeY / 2}
			{x: x + sizeX / 2, y: y}
			{x: x, y: y + sizeY / 2}
			{x: x - sizeX / 2, y: y}
		}
		return output
	
	Draw: (x = 0, y = 0, size = 1, centered = true) =>
		return if SERVER
		if not @IsError() and not @forceDrawDefault
			surface.SetMaterial(@material)
			surface.DrawTexturedRect(x, y, @Width() * size, @Height() * size) if not centered
			surface.DrawTexturedRect(x - @Width() / 2 * size, y - @Height() / 2 * size, @Width() * size, @Height() * size) if centered
			draw.NoTexture()
		else
			draw.NoTexture()
			surface.DrawPoly(@@GENERATE_POLY(x, y, @Width() * size, @Height() * size)) if centered
			surface.DrawPoly(@@GENERATE_POLY(x - @Width() * size / 2, y - @Height() * size / 2, @Width() * size, @Height() * size)) if not centered
	
	@LoadFromName: (str, forceDrawDefault) => Icon(str, forceDrawDefault)
	@GetDefaultIcon: (forceDrawDefault) => Icon(@AvaliableBare[1], forceDrawDefault)
	@DefaultIcon: (forceDrawDefault) => Icon(@AvaliableBare[1], forceDrawDefault)
	GetSaveName: => @bareName
	GetName: => @bareName
	GetID: => @ID
	GetFullName: => @nameFull
	GetPath: => @file
	GetMaterial: => @material
	GetSize: => @@SIZE_X, @@SIZE_Y
	Height: => @@SIZE_Y
	Width: => @@SIZE_X
	
	-- Some aliases for IMaterial
	GetColor: (...) => @material\GetColor(...) if CLIENT
	GetFloat: (...) => @material\GetFloat(...) if CLIENT
	GetInt: (...) => @material\GetInt(...) if CLIENT
	GetKeyValues: (...) => @material\GetKeyValues(...) if CLIENT
	GetMatrix: (...) => @material\GetMatrix(...) if CLIENT
	GetShader: (...) => @material\GetShader(...) if CLIENT
	GetString: (...) => @material\GetString(...) if CLIENT
	GetTexture: (...) => @material\GetTexture(...) if CLIENT
	GetVector: (...) => @material\GetVector(...) if CLIENT
	Recompute: (...) => @material\Recompute(...) if CLIENT
	SetFloat: (...) => @material\SetFloat(...) if CLIENT
	SetInt: (...) => @material\SetInt(...) if CLIENT
	SetMatrix: (...) => @material\SetMatrix(...) if CLIENT
	SetShader: (...) => @material\SetShader(...) if CLIENT
	SetString: (...) => @material\SetString(...) if CLIENT
	SetTexture: (...) => @material\SetTexture(...) if CLIENT
	SetUndefined: (...) => @material\SetUndefined(...) if CLIENT
	SetVector: (...) => @material\SetVector(...) if CLIENT
	
	IsValid: => not @IsError()
	IsError: =>
		if not @valid return false
		return @@FILES[@file] if SERVER
		return @material\IsError()

DMaps.Icon = Icon
return Icon