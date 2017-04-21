
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

import CAMI, DMaps, LocalPlayer, error, table from _G

WATCHING_PERMISSIONS = {}
WATCHING_PERMISSIONS_MAP = {}

DMaps.WatchPermission = (perm = '') ->
    error("Invalid permission to watch: #{perm}") if not DMaps.IsValidPermission(perm)
    perm = DMaps.TranslatePermission(perm)
    return if table.HasValue(WATCHING_PERMISSIONS, perm)
    table.insert(WATCHING_PERMISSIONS, perm)
    if LocalPlayer()\IsValid()
        CAMI.PlayerHasAccess LocalPlayer(), perm, (has = false, reason = '') -> WATCHING_PERMISSIONS_MAP[perm] = has

DMaps.HasPermission = (perm = '') ->
    error("Invalid permission to check: #{perm}") if not DMaps.IsValidPermission(perm)
    perm = DMaps.TranslatePermission(perm)
    error("Permission is not tracked: #{perm}") if WATCHING_PERMISSIONS_MAP[perm] == nil
    return WATCHING_PERMISSIONS_MAP[perm]

timer.Create 'DMaps.ClientsidePermissionsWatchdog', 10, 0, ->
    ply = LocalPlayer()
    for perm in *WATCHING_PERMISSIONS
        CAMI.PlayerHasAccess ply, perm, (has = false, reason = '') -> WATCHING_PERMISSIONS_MAP[perm] = has