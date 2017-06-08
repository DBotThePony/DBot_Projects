
--
-- Copyright (C) 2016-2017 DBot
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

DScoreBoard2.FONT_SERVERTITLE = 'DScoreBoard2.ServerTitle'
DScoreBoard2.FONT_MOUSENOTIFY = 'DScoreBoard2.MouseNotify'
DScoreBoard2.FONT_TOPINFO = 'DScoreBoard2.TopInfoText'
DScoreBoard2.FONT_BOTTOMINFO = 'DScoreBoard2.BottomInfoText'
DScoreBoard2.FONT_PLAYERINFO = 'DScoreBoard2.PlayerInfoText'
DScoreBoard2.FONT_BUTTONFONT = 'DScoreBoard2.Button'
DScoreBoard2.FONT_RATING = 'DScoreBoard2.Ratings'

surface.CreateFont(DScoreBoard2.FONT_SERVERTITLE, {
	font = 'Roboto',
	size = 50,
	extended = true,
	weight = 800,
})

surface.CreateFont(DScoreBoard2.FONT_MOUSENOTIFY, {
	font = 'Roboto',
	size = 30,
	extended = true,
	weight = 500,
})

surface.CreateFont(DScoreBoard2.FONT_TOPINFO, {
	font = 'Roboto',
	size = 16,
	extended = true,
	weight = 600,
})

surface.CreateFont(DScoreBoard2.FONT_BOTTOMINFO, {
	font = 'Roboto',
	size = 13,
	extended = true,
	weight = 500,
})

surface.CreateFont(DScoreBoard2.FONT_PLAYERINFO, {
	font = 'Roboto',
	size = 16,
	extended = true,
	weight = 500,
})

surface.CreateFont(DScoreBoard2.FONT_BUTTONFONT, {
	font = 'Roboto',
	size = 16,
	extended = true,
	weight = 500,
})

surface.CreateFont(DScoreBoard2.FONT_RATING, {
	font = 'Roboto',
	size = 12,
	extended = true,
	weight = 500,
})