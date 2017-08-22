
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

include 'shared.lua'

ENT.Initialize = =>
    @BaseClass.Initialize(@)
    @idleSound = CreateSound(@, 'weapons/dispenser_idle.wav')
    @idleSound\ChangeVolume(0.75)
    @idleSound\SetSoundLevel(75)
    @idleSound\Play()
    @lastArrowAngle = 0

ENT.OnRemove = =>
    @idleSound\Stop() if @idleSound

ENT.Think = =>
    @BaseClass.Think(@)
    @idleSound\Stop() if not @IsAvaliable() and @idleSound\IsPlaying()
    @idleSound\Play() if @IsAvaliable() and not @idleSound\IsPlaying()

SCREEN_BG_RED = Material('vgui/dispenser_meter_bg_red')
SCREEN_BG_BLUE = Material('vgui/dispenser_meter_bg_blue')
SCREEN_BG_ARROW = Material('vgui/dispenser_meter_arrow')

SCREEN_DIST = 7
SCREEN_POS_1 = Vector(SCREEN_DIST, 1, 42)
ARROW_POS_1 = Vector(SCREEN_DIST + .1, 1, 38)
SCREEN_POS_2 = Vector(-SCREEN_DIST, 1, 42)
ARROW_POS_2 = Vector(-SCREEN_DIST - 0.1, 1, 38)
SCREEN_COLOR = Color(255, 255, 255)

WIDTH = 256 / 12
HEIGHT = 128 / 12

WIDTH_ARROW = 32 / 12
HEIGHT_ARROW = 128 / 12

ENT.Draw = =>
    @BaseClass.Draw(@)
    return if @GetIsBuilding()
    screenMat = SCREEN_BG_BLUE if @GetTeamType()
    screenMat = SCREEN_BG_RED if not @GetTeamType()
    lpos = @GetPos()
    ang = @GetAngles()
    fwd = ang\Forward()

    @lastArrowAngle = Lerp(0.1, @lastArrowAngle, @GetAvaliablePercent() * 180)
    render.OverrideDepthEnable(true, true)
    
    do
        pos = Vector(SCREEN_POS_1)
        pos\Rotate(ang)
        pos += lpos
        render.SetMaterial(screenMat)
        render.DrawQuadEasy(pos, fwd, WIDTH, HEIGHT, SCREEN_COLOR, 180)
    
    do
        pos = Vector(ARROW_POS_1)
        pos\Rotate(ang)
        pos += lpos
        rad = -math.rad(@lastArrowAngle)
        sin, cos = math.sin(rad), math.cos(rad)
        addVector = Vector(0, -cos * 4.5, -sin * 4.5)
        addVector\Rotate(ang)
        pos += addVector

        render.SetMaterial(SCREEN_BG_ARROW)
        render.DrawQuadEasy(pos, fwd, WIDTH_ARROW, HEIGHT_ARROW, SCREEN_COLOR, -90 - @lastArrowAngle)
    
    do
        pos = Vector(SCREEN_POS_2)
        pos\Rotate(ang)
        pos += lpos
        render.SetMaterial(screenMat)
        render.DrawQuadEasy(pos, -fwd, WIDTH, HEIGHT, SCREEN_COLOR, 180)
    
    do
        pos = Vector(ARROW_POS_2)
        pos\Rotate(ang)
        pos += lpos

        rad = -math.rad(@lastArrowAngle + 180)
        sin, cos = math.sin(rad), math.cos(rad)
        addVector = Vector(0, -cos * 4.5, sin * 4.5)
        addVector\Rotate(ang)
        pos += addVector

        render.SetMaterial(SCREEN_BG_ARROW)
        render.DrawQuadEasy(pos, -fwd, WIDTH_ARROW, HEIGHT_ARROW, SCREEN_COLOR, -90 - @lastArrowAngle)

    render.OverrideDepthEnable(false, true)
