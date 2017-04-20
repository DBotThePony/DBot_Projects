
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

PANEL =
	Init: =>
		@SetSize(400, 25)
		@DockMargin(5, 2, 5, 2)
		@name = vgui.Create('DLabel', @)
		@OnUpdate = ->
		@data = {}
		
		with @name
			\SetText('%WAYPOINTNAME%')
			\Dock(LEFT)
			\DockMargin(5, 0, 5, 0)
			\SetSize(200, 100)
			\SetColor(color_white)
		
		@posx = vgui.Create('DLabel', @)
		with @posx
			\SetText("X: #{@data.posx}")
			\Dock(LEFT)
			\DockMargin(5, 0, 5, 0)
			\SetSize(60, 60)
			\SetColor(color_white)
		
		@posy = vgui.Create('DLabel', @)
		with @posy
			\SetText("Y: #{@data.posy}")
			\Dock(LEFT)
			\DockMargin(5, 0, 5, 0)
			\SetSize(60, 60)
			\SetColor(color_white)
		
		@posz = vgui.Create('DLabel', @)
		with @posz
			\SetText("Z: #{@data.posz}")
			\Dock(LEFT)
			\DockMargin(5, 0, 5, 0)
			\SetSize(60, 60)
			\SetColor(color_white)
		
		@color = vgui.Create('EditablePanel', @)
		with @color
			\Dock(LEFT)
			\DockMargin(5, 5, 5, 5)
			\SetSize(60, 60)
			pnl = @
			.Paint = (w, h) =>
				if not pnl.data.red return
				surface.SetDrawColor(pnl.data.red, pnl.data.green, pnl.data.blue)
				surface.DrawRect(0, 0, w, h)
		
		@edit = vgui.Create('DButton', @)
		with @edit
			\Dock(RIGHT)
			\DockMargin(5, 2, 5, 2)
			\SetSize(100, 60)
			\SetText('Edit Waypoint...')
			.DoClick = -> DMaps.OpenWaypointEditMenu(@id, @container, nil, -> @OnUpdate())
		
		@visible = vgui.Create('DButton', @)
		with @visible
			\Dock(RIGHT)
			\DockMargin(5, 2, 5, 2)
			\SetSize(100, 60)
			if @data.visible
				\SetText('Make invisible')
			else
				\SetText('Make visible')
			.DoClick = ->
				@container\SetVisible(@id, not @data.visible)
				@OnUpdate()
				if @data.visible
					\SetText('Make visible')
				else
					\SetText('Make invisible')
		
		@delete = vgui.Create('DButton', @)
		with @delete
			\Dock(RIGHT)
			\DockMargin(5, 2, 5, 2)
			\SetSize(100, 60)
			\SetText('Delete waypoint')
			.DoClick = ->
				btnconfirmed = ->
					@container\DeleteWaypoint(@id)
					@OnUpdate()
				Derma_Query("Delete waypoint №#{@id} (#{@data.name})?\nIt will be gone forever!\n(A long time!)", "Delete waypoint №#{@id} (#{@data.name})?", 'Confirm', btnconfirmed, 'Cancel', (->))
	Paint: (w, h) =>
		surface.SetDrawColor(130, 130, 130)
		surface.DrawRect(0, 0, w, h)
	SetData: (id, container) =>
		@container = container
		@id = id
		@data = container\GetPoint(id)
		@UpdatePanels()
	SetOnUpdate: (func = (->)) =>
		@OnUpdate = func
	UpdatePanels: =>
		@name\SetText(@data.name)
		@posx\SetText("X: #{@data.posx}")
		@posy\SetText("Y: #{@data.posy}")
		@posz\SetText("Z: #{@data.posz}")
		if @data.visible
			@visible\SetText('Make invisible')
		else
			@visible\SetText('Make visible')
DMaps.PANEL_WAYPOINT_ROW = PANEL
vgui.Register('DMapsWaypointRow', PANEL, 'EditablePanel')
return PANEL