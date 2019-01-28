
--
-- Copyright (C) 2017-2019 DBot

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
-- of the Software, and to permit persons to whom the Software is furnished to do so,
-- subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all copies
-- or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
-- INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
-- PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
-- FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
-- DEALINGS IN THE SOFTWARE.


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
    sPerm = perm
    error("Invalid permission to check: #{perm}") if not DMaps.IsValidPermission(perm)
    perm = DMaps.TranslatePermission(perm)
    if WATCHING_PERMISSIONS_MAP[perm] == nil
        DMaps.WatchPermission(sPerm)
        return false
    return WATCHING_PERMISSIONS_MAP[perm]

timer.Create 'DMaps.ClientsidePermissionsWatchdog', 10, 0, ->
    ply = LocalPlayer()
	return if not IsValid(ply) or not ply.UniqueID -- breakage fix
    for perm in *WATCHING_PERMISSIONS
        CAMI.PlayerHasAccess ply, perm, (has = false, reason = '') -> WATCHING_PERMISSIONS_MAP[perm] = has