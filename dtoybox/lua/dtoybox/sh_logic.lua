
-- Copyright (C) 2018 DBot

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

local DToyBox = DToyBox
local DLib = DLib
local LocalPlayer = LocalPlayer
local CLIENT = CLIENT
local RealTimeL = RealTimeL
local ipairs = ipairs
local assert = assert
local type = type
local table = table
local hook = hook

DToyBox.DownloadListing = DToyBox.DownloadListing or {}

CAMI.RegisterPrivilege({
	Name = 'toybox_load',
	MinAccess = 'superadmin',
	Description = 'Allow player to load toybox addons ON SERVER'
})

local watchdog = DLib.CAMIWatchdog('toybox_checkup', nil, 'toybox_load')

function DToyBox.CanCommand(ply)
	if CLIENT then
		return watchdog:HasPermission('toybox_load')
	end

	return watchdog:HasPermission(ply, 'toybox_load')
end

function DToyBox.CheckListing()
	for i, value in ipairs(DToyBox.DownloadListing) do
		if not value.init then
			if not value.bundle:IsLoaded() then
				break
			end

			value.init = true
			value.bundle:Run()
		end
	end
end

function DToyBox.ShouldLoadAddon(wsid)
	assert(type(wsid) == 'number', 'WorkshopID must be a number!')
	assert(wsid > 0, 'Invalid workshopid')

	for i, value in ipairs(DToyBox.DownloadListing) do
		if value.wsid == wsid then
			return false
		end
	end

	return true
end

function DToyBox.LoadAddon(wsid)
	assert(type(wsid) == 'number', 'WorkshopID must be a number!')
	assert(wsid > 0, 'Invalid workshopid')

	if SERVER then
		net.Start('dtoybox.addaddon')
		net.WriteUInt32(wsid)
		net.Broadcast()
	end

	hook.Run('DToyBox.ItemAdded', wsid)

	for i, value in ipairs(DToyBox.DownloadListing) do
		if value.wsid == wsid then
			table.remove(DToyBox.DownloadListing, i)
			break
		end
	end

	local fbundle = VLL2.WSBundle(tostring(wsid))
	fbundle:DoNotReplicate()
	fbundle:DoNotInitAfterLoad()
	fbundle:DoNotMountAfterLoad()

	fbundle:AddLoadedHook(DToyBox.CheckListing)
	fbundle:Load()

	local data = {
		bundle = fbundle,
		init = false,
		wsid = wsid,
		stamp = RealTimeL()
	}

	table.insert(DToyBox.DownloadListing, data)
	return data
end
