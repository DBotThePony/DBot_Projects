
-- Copyright (C) 2017-2018 DBot

-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at

--     http://www.apache.org/licenses/LICENSE-2.0

-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

import Notify from DLib

HUInMeter = 40
DISABLE = CreateConVar('cl_ac_disable', '0', {FCVAR_ARCHIVE}, 'Disable action counter display')

NetworkedValues = {
	{'jump'}
	{'speed'}
	{'duck'}
	{'walk'}
	{'water'}
	{'uwater'}
	{'fall'}
	{'climb'}
	{'height'}
}

for value in *NetworkedValues
	value[2] = "gui.actioncounter.#{value[1]}"

for nData in *NetworkedValues
	nData.func = =>
		if nData.lastChange > RealTime! - 4
			if nData[1] ~= 'jump'
				@SetText(DLib.i18n.localize(nData[2], math.floor(nData.networkValue / HUInMeter * 10) / 10))
			else
				@SetText(DLib.i18n.localize(nData[2], nData.networkValue))
				
			@ExtendTimer!

NET = ->
	if DISABLE\GetBool() then return
	for nData in *NetworkedValues
		readValue = net.ReadUInt(32)
		if readValue == 0 then continue
		nData.networkValue = nData.networkValue or readValue
		changed = nData.networkValue ~= readValue
		nData.networkValue = readValue
		
		if changed
			nData.lastChange = RealTime!

Think = ->
	if DISABLE\GetBool() then return
	ctime = RealTime! - 4
	
	for nData in *NetworkedValues
		if nData.lastChange and nData.lastChange > ctime
			if not nData.notif or not nData.notif\IsValid!
				nData.notif = Notify.CreateSlide()
				nData.notif\SetThink(nData.func)
				nData.notif\SetNotifyInConsole(false)
				nData.notif\Start()
				nData.notif\Think()
				
	
hook.Add('Think', 'DActionCounter', Think)
net.Receive('dactioncounter_network', NET)

return
