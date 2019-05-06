
--
-- Copyright (C) 2017-2019 DBotThePony
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

import hook, util, DarkRP, net from _G

if not DarkRP return

SV_ENABLE_ARREST = CreateConVar('sv_dmaps_arrest_enable', '1', {FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Enable DarkRP arrest events display')

AddNetworkString = (n) -> util.AddNetworkString "DMaps.DarkRP.#{n}"
Start = (n) -> net.Start "DMaps.DarkRP.#{n}"

AddNetworkString 'playerArrested'
AddNetworkString 'playerUnArrested'

hook.Add 'playerArrested', 'DMaps.DarkRP', (criminal = NULL, time = 0, arrester = NULL) ->
	return if not SV_ENABLE_ARREST\GetBool()
	return if not IsValid(criminal) or not IsValid(arrester)
	return if not criminal\IsPlayer() or not arrester\IsPlayer()
	Start('playerArrested')
	net.WriteEntity(criminal)
	net.WriteEntity(arrester)
	net.WriteVector(criminal\GetPos())
	net.Broadcast()

hook.Add 'playerUnArrested', 'DMaps.DarkRP', (criminal = NULL, unarrester = NULL) ->
	return if not SV_ENABLE_ARREST\GetBool()
	return if not IsValid(criminal)
	return if not criminal\IsPlayer() or IsValid(unarrester) and not unarrester\IsPlayer()
	valid = IsValid(unarrester)
	Start('playerUnArrested')
	net.WriteEntity(criminal)
	net.WriteBool(valid)
	net.WriteEntity(unarrester) if valid
	net.WriteVector(criminal\GetPos())
	net.Broadcast()

