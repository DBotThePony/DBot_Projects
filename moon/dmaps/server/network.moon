
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

import util from _G

util.AddNetworkString 'DMaps.AdminEcho'
util.AddNetworkString 'DMaps.NetworkedWaypoint'
util.AddNetworkString 'DMaps.NetworkedWaypointChanges'
util.AddNetworkString 'DMaps.NetworkedWaypointRemoved'
util.AddNetworkString 'DMaps.NPCDeath'
util.AddNetworkString 'DMaps.PlayerDeath'

for str in *{'BasicWaypoint', 'CAMIWaypoint', 'UsergroupWaypoint', 'TeamWaypoint'}
	util.AddNetworkString "DMaps.#{str}Load"
	util.AddNetworkString "DMaps.#{str}Modify"
	util.AddNetworkString "DMaps.#{str}Create"
	util.AddNetworkString "DMaps.#{str}Delete"
