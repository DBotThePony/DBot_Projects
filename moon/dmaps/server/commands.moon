
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

import concommand, Vector, MsgC, NULL, tonumber, team from _G

TeleportTo = (ply, x, y, z) ->
	if not ply\IsValid() return
	CAMI.PlayerHasAccess ply, 'dmaps_teleport', (has = false, reason = '') ->
		if not has return
		if not x return
		if not y return
		if not z return
		if not ply\Alive() return
		ply\SetPos(Vector(x, y, z))
		DMaps.AdminEcho('Admin ', ply, ' has teleported to X: ', x, ' Y: ', y, ' Z: ', z)
concommand.Add('dmaps_teleport', (ply = NULL, cmd = '', args = {}) -> TeleportTo(ply, tonumber(args[1]), tonumber(args[2]), tonumber(args[3])))
