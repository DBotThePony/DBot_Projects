
--
-- Copyright (C) 2017 DBot
-- 
-- Licensed under the Apache License, Version 2.0 (the 'License');
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
-- 
--     http://www.apache.org/licenses/LICENSE-2.0
-- 
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an 'AS IS' BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
-- 

import DMaps, timer, CreateConVar, draw, surface, Color from _G
import EventPointer, Icon, DMapWaypoint from DMaps

SV_DEATH_POINT_DURATION = CreateConVar('sv_dmaps_deathpoints_duration', '15', {FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Player death point live time in minutes')
DRAW_DEATHPOINTS = DMaps.ClientsideOption('draw_deathpoints', '1', 'Draw deathpoints on map')
DRAW_DEATHPOINTS_PLAYERS = DMaps.ClientsideOption('draw_deathpoints_player', '1', 'Draw player deathpoints on map')

class DeathPointer extends EventPointer
	GetRenderPriority: => -10
	@TextColor = Color(200, 200, 200)
	@BackgroundColor = Color(0, 0, 0, 150)
	@DefaultColor = Color(233, 89, 89)
	@GetDefaultTime = => @DefaultLiveTime

	-- https://git.dbot.serealia.ca/dbot/dbot_projects/tree/master/tdeaths
	@DeathReasonsDict = {
		Fall: {
			'%s fell from high place'
			'%s hit the ground too hard'
			"%s fell to their death"
			"%s didn't bounce"
			"%s fell victim of gravity"
			"%s faceplanted the ground"
			"%s left a small crater"
			'%s likes to be smashed'
			'%s forgot to open his parachute'
			'%s forgot to open his wings'
			'%s became an angel'
			'%s was falling too long'
		}

		Drowned: {
			"%s forgot to breathe"
			"%s is sleeping with the fishes"
			"%s drowned"
			"%s became a seapony"
			"%s's lungs is filled with wrong liquid"
			"%s is shark food"
		}

		Fire: {
			'%s likes to play with fire'
			'%s burned to the crisp'
			'%s burned to the death'
			'%s became an ach'
			'%s was cooked alive'
		}

		Default: {
			"%s was slain"
			"%s was eviscerated"
			"%s was murdered"
			"%s's face was torn off"
			"%s's entrails were ripped out"
			"%s was destroyed"
			"%s's skull was crushed"
			"%s got massacred"
			"%s got impaled"
			"%s was torn in half"
			"%s was decapitated"
			"%s let their arms get torn off"
			"%s watched their innards become outards"
			"%s was brutally dissected"
			"%s's extremities were detached"
			"%s's body was mangled"
			"%s's vital organs were ruptured"
			"%s was turned into a pile of flesh"
			"%s's body was removed from this server"
			"%s was terminated"
			"%s got snapped in half"
			"%s was cut down the middle"
			"%s was chopped up"
			"%s's plead for death was answered"
			"%s's meat was ripped off the bone"
			"%s's flailing about was finally stopped"
			"%s had their head removed"
			"%s got a bullet in his head"
			"%s become a useless body"
			"%s gone to paradise"
			"%s's life was finished"
			"%s gone from this world"
			"%s's game was overed"
			"%s lost any of his blood"
			"%s lost his life connection"
			"%s's mind was damaged"
			"%s got pulverizered"
			"%s's brain was turned into forcemeat"
		}

		Poison: {
			'%s was poisoned to the death'
			'%s\'s veins was poisoned'
			'%s blood were turned into water'
		}

		Acid: {
			'%s disappeared'
			'%s was digested'
			'%s\'s vital organs were ruptured'
			'%s got splitted'
			'%s got disintegrated by acid'
			'%s got disassembled'
			'%s was oxidized'
			'%s tried to swin in acid'
		}
		
		Slash: {
			'%s got snapped in half'
			'%s was cut down the middle'
			'%s was chopped up'
			'%s was butchered by a knife'
			'%s turned into meat steak'
			'%s was butchered'
			'%s catched a cleaver by his head'
			"%s's face was torn off"
			"%s was turned into a pile of flesh"
			"%s had their head removed"
			"%s was torn in half"
			"%s got pulverizered"
		}
		
		Electricity: {
			'%s was hit by lighting'
			'%s played and died because of electricity'
			'%s got shocked to the death'
			'%s was zapped like a bee'
			'%s was cooked by electricity'
			'%s became a live battery'
			'%s was charged by electrons'
			'%s got plus and minus polarity'
			'%s loves to play with electricity'
			"%s didn't wear gloves while working with electricity"
			'%s got a heart attack because of electricity'
			'%s\'s heart got wrong electricity'
			'%s got cooked'
		}
		
		Laser: {
			'%s got snapped in half'
			'%s received much heat and melted'
			'%s was melted'
			'%s was perfectly cut'
			'%s\'s body got splitted'
			'%s fell at open laser'
			'%s was cut by a laser'
		}
		
		Disintegrated: {
			"%s gone from this world"
			"%s was terminated"
			"%s's body was removed from this server"
			"%s disappeared"
			"%s was disintegrated"
			"%s's body was divided into atoms"
			"%s's atmos disintegrated"
		}
		
		Explosion: {
			'%s was blown up'
			'%s\' organs is flying around'
			'%s got a grenade in his eye'
			'%s catched a rocket in wrong way'
			'%s was butchered'
			"%s's meat was ripped off the bone"
			'%s got impacted to second world'
			'%s got dismembered'
			'%s explodes'
			'BOOM! Wee now can see %s\'s meat around'
		}
	}

	@DeathReasonsDamage = {
		[DMG_BLAST]: @DeathReasonsDict.Explosion
		[DMG_BLAST_SURFACE]: @DeathReasonsDict.Explosion
		
		[DMG_SLASH]: @DeathReasonsDict.Slash
		[DMG_CLUB]: @DeathReasonsDict.Slash
		[DMG_ENERGYBEAM]: @DeathReasonsDict.Laser
		[DMG_PLASMA]: @DeathReasonsDict.Laser
		[DMG_DISSOLVE]: @DeathReasonsDict.Disintegrated
		[DMG_SHOCK]: @DeathReasonsDict.Electricity
		
		[DMG_GENERIC]: @DeathReasonsDict.Default
		[DMG_BULLET]: @DeathReasonsDict.Default
		[DMG_BUCKSHOT]: @DeathReasonsDict.Default
		[DMG_DIRECT]: @DeathReasonsDict.Default
		
		[DMG_CRUSH]: @DeathReasonsDict.Prop
		[DMG_PHYSGUN]: @DeathReasonsDict.Prop
		[DMG_BURN]: @DeathReasonsDict.Fire
		[DMG_SLOWBURN]: @DeathReasonsDict.Fire
		[DMG_DROWN]: @DeathReasonsDict.Drowned
		[DMG_DROWNRECOVER]: @DeathReasonsDict.Drowned
		[DMG_FALL]: @DeathReasonsDict.Fall
		[DMG_PARALYZE]: @DeathReasonsDict.Poison
		[DMG_NERVEGAS]: @DeathReasonsDict.Poison
		[DMG_POISON]: @DeathReasonsDict.Poison
		[DMG_ACID]: @DeathReasonsDict.Acid
		[DMG_RADIATION]: @DeathReasonsDict.Acid
	}

	SetDamageType: (tp = DMG_GENERIC) =>
		tp = DMG_GENERIC if not @@DeathReasonsDamage[tp]
		@dmgType = tp
		@deathPhrase = table.Random(@@DeathReasonsDamage[tp])
		@deathPhraseF = string.format(@deathPhrase, @GetName())

	@DEATH_POINTS = {}

	new: (name = 'Perfectly generic death', x = 0, y = 0, z = 0, color = @@DefaultColor, yaw = 0, size = 1, dmgType = DMG_GENERIC) =>
		super(name, x, y, z, color)
		@_dPointID = table.insert(@@DEATH_POINTS, @)
		@SetDamageType(dmgType)
	GetText: => "#{@deathPhraseF}\n#{@NiceTime()} ago#{DMaps.DeltaString(@z)}"
	SetName: (...) =>
		super(...)
		@deathPhraseF = string.format(@deathPhrase, @GetName())
	Remove: =>
		super()
		@@DEATH_POINTS[@_dPointID] = nil

	Draw: (map) =>
		return if not DRAW_DEATHPOINTS\GetBool()
		super(map)

class PlayerDeathPointer extends DeathPointer
	new: (ply = NULL, x = 0, y = 0, z = 0, dmgType = DMG_GENERIC) =>
		@ply = ply
		super(@ply\Nick(), x, y, z, team.GetColor(@ply\Team()), math.random(-180, 180), 1, dmgType)
		@SetLiveTime(SV_DEATH_POINT_DURATION\GetFloat() * 60)
		@nick = ply\Nick()
		@userid = ply\UserID()
		@steamid = ply\SteamID()
		@steamid64 = ply\SteamID64()
		@uniqueid = ply\UniqueID()
		@SteamName = ply\SteamName() if ply.SteamName
	OpenMenu: (menu = DermaMenu()) =>
		super(menu)
		with menu
			\AddSpacer()
			\AddOption('Copy Steam Name', -> SetClipboardText(tostring(@SteamName)))\SetIcon(table.Random(DMaps.TAGS_ICONS)) if @SteamName
			\AddOption('Copy UserID', -> SetClipboardText(tostring(@userid)))\SetIcon(table.Random(DMaps.TAGS_ICONS))
			\AddOption('Copy SteamID', -> SetClipboardText(tostring(@steamid)))\SetIcon(table.Random(DMaps.TAGS_ICONS))
			\AddOption('Copy SteamID64', -> SetClipboardText(tostring(@steamid64)))\SetIcon(table.Random(DMaps.TAGS_ICONS))
			\AddOption('Copy UniqueID', -> SetClipboardText(tostring(@uniqueid)))\SetIcon(table.Random(DMaps.TAGS_ICONS))
			\AddOption('Open steam profile', -> gui.OpenURL("http://steamcommunity.com/profiles/#{@steamid64}/"))\SetIcon('icon16/link.png')
			\Open()
		return true
	Draw: (map) =>
		return if not DRAW_DEATHPOINTS_PLAYERS\GetBool()
		super(map)


DMaps.DeathPointer = DeathPointer
DMaps.PlayerDeathPointer = PlayerDeathPointer

local LAST_DEATH_POINT
REMEMBER_DEATH_POINT = DMaps.ClientsideOption('remember_death', '1', 'Remember last death point')
DEATH_POINT_COLOR = DMaps.CreateColor(255, 255, 255, 'remember_death', 'Latest death point color')

netDMGTable = {
	DMG_BLAST
	DMG_BLAST_SURFACE
	DMG_SLASH
	DMG_CLUB
	DMG_ENERGYBEAM
	DMG_PLASMA
	DMG_DISSOLVE
	DMG_SHOCK
	DMG_GENERIC
	DMG_BULLET
	DMG_BUCKSHOT
	DMG_DIRECT
	DMG_CRUSH
	DMG_PHYSGUN
	DMG_BURN
	DMG_SLOWBURN
	DMG_DROWN
	DMG_DROWNRECOVER
	DMG_FALL
	DMG_PARALYZE
	DMG_NERVEGAS
	DMG_POISON
	DMG_ACID
	DMG_RADIATION
}

class DMapsLocalDeathPoint extends DMapWaypoint
	new: (x = 0, y = 0, z = 0) =>
		super('Latest death', x, y, z, Color(DEATH_POINT_COLOR()), 'skull_old')
	
	OpenMenu: (menu = DermaMenu()) =>
		super(menu)
		with menu
			\AddOption('Remove death point', -> @Remove())\SetIcon('icon16/cross.png')
			\Open()
		return true

net.Receive 'DMaps.PlayerDeath', ->
	ply = net.ReadEntity()
	{:x, :y, :z} = net.ReadVector()

	if not IsValid(ply) return
	if ply == LocalPlayer()
		return if not REMEMBER_DEATH_POINT\GetBool()
		x, y, z = math.floor(x), math.floor(y), math.floor(z)
		LAST_DEATH_POINT\Remove() if IsValid(LAST_DEATH_POINT)
		LAST_DEATH_POINT = DMapsLocalDeathPoint(x, y, z)
		hook.Run 'DMaps.PlayerDeath', ply, LAST_DEATH_POINT
		DMaps.ChatPrint('You died at X: ', x, ' Y: ', y, ' Z: ', z)
		return
	
	hasDMG = net.ReadBool()
	dmgType = netDMGTable[net.ReadUInt(8)] if hasDMG
	point = PlayerDeathPointer(ply, x, y, z, dmgType)
	hook.Run 'DMaps.PlayerDeath', ply, point
