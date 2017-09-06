
--
-- Copyright (C) 2017 DBot
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http\//www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

include 'shared.lua'

net.Receive 'SCP-219Menu', ->
    ent = net.ReadEntity()
	
	if not IsValid(ent) return
	
	self = vgui.Create('DFrame')
	@SetSize(200, 150)
	@SetTitle('SCP-219')
	@Center()
	@MakePopup()
	
	lab = @Add('DLabel')
	lab\SetText('Strength (min 1):')
	lab\Dock(TOP)
	
	entry = @Add('DTextEntry')
	entry\SetText('1')
	entry\Dock(TOP)

	timer.Simple 0.1, -> input.SetCursorPos(entry\LocalToScreen(5, 8))
	
	lab = @Add('DLabel')
	lab\SetText('Duration (min 6):')
	lab\Dock(TOP)
	
	entry2 = @Add('DTextEntry')
	entry2\SetText('15')
	entry2\Dock(TOP)
	
	button = @Add('DButton')
	button\SetText('Launch')
	button.DoClick = ->
		strength = tonumber(entry\GetText())
		duration = tonumber(entry2\GetText())
		
		if strength and duration and strength >= 1 and duration > 5
			net.Start('SCP-219Menu')
			net.WriteEntity(ent)
			net.WriteUInt(math.ceil(strength), 32)
			net.WriteUInt(math.ceil(duration), 32)
			net.SendToServer()
		@Close()
	button\Dock(TOP)
