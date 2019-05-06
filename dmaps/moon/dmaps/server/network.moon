
--
-- Copyright (C) 2017-2019 DBotThePony
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
import AddNetworkString from util
_AddNetworkString = AddNetworkString
AddNetworkString = (n) -> _AddNetworkString "DMaps.#{n}"

AddNetworkString 'AdminEcho'
AddNetworkString 'NetworkedWaypoint'
AddNetworkString 'NetworkedWaypointChanges'
AddNetworkString 'NetworkedWaypointRemoved'
AddNetworkString 'NPCDeath'
AddNetworkString 'PlayerDeath'
AddNetworkString 'Navigation.Require'
AddNetworkString 'Navigation.NotInstalled'
AddNetworkString 'Navigation.Info'
AddNetworkString 'Navigation.Stop'
AddNetworkString 'ConsoleMessage'
AddNetworkString 'Notify'
AddNetworkString 'ChatMessage'
AddNetworkString 'Sharing'

for str in *{'BasicWaypoint', 'CAMIWaypoint', 'UsergroupWaypoint', 'TeamWaypoint'}
	AddNetworkString "#{str}Load"
	AddNetworkString "#{str}Modify"
	AddNetworkString "#{str}Create"
	AddNetworkString "#{str}Delete"
