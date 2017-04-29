
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

import DMaps, navmesh, table from _G
import Vector from _G

class AStarNode
	new: (nav, g = 0, target = Vector(0, 0, 0)) =>
		@nav = nav
		@pos = @nav\GetCenter()
		@target = target
		@g = g
		@h = target\DistToSqr(@pos)
		@f = @g + @h
	
	SetG: (val = 0) =>
		@g = val
		@f = @g + @h
	SetH: (val = 0) =>
		@h = val
		@f = @g + @h
	SetFrom: (val) =>
		@from = val
	
	__tostring: => "[DMaps:AStarNode:#{@nav}]"

	GetG: => @g
	GetH: => @h
	GetF: => @f
	GetPos: => @pos
	GetFrom: => @from
	HasParent: => @from ~= nil
	GetParent: => @from
	GetAdjacentAreas: => @nav\GetAdjacentAreas()
	Underwater: => @nav\IsUnderwater()

class AStarTracer
	@nextID = 1

	new: (startPos = Vector(0, 0, 0), endPos = Vector(0, 0, 0), loopsPerIteration = 50, limit = 2000, frameThersold = 5, timeThersold = 1500) =>
		@ID = @@nextID
		@@nextID += 1
		@working = false
		@hasfinished = false
		@failure = false
		@success = false
		@stop = false
		@opened = {}
		@closed = {}
		@database = {}
		@points = {startPos, endPos}
		@startPos = startPos
		@endPos = endPos
		@loopsPerIteration = loopsPerIteration
		@limit = limit
		@hasLimit = limit ~= 0
		@frameThersold = frameThersold
		@timeThersold = timeThersold
		@totalTime = 0
		@nodesLimit = 400
		@callbackFail = =>
		@callbackSuccess = =>
		@callbackStop = =>
	
	IsStopped: => @stop
	IsWorking: => @working
	IsSuccess: => @success
	IsFailure: => @failure
	IsFinished: => @hasfinished
	HasFinished: => @hasfinished

	SetSuccessCallback: (val = (=>)) =>
		@callbackSuccess = val
	SetFailCallback: (val = (=>)) =>
		@callbackFail = val
	SetFailureCallback: (val = (=>)) =>
		@callbackFail = val
	SetStopCallback: (val = (=>)) =>
		@callbackStop = val

	__tostring: => "[DMaps:AStarTracer:#{@ID}]"
	GetNode: (nav) =>
		for data in *@database
			return data if data.nav == nav
	AddNode: (node) => table.insert(@database, node)

	GetPath: => @points
	GetPoints: => @points
	RecalcPath: =>
		return @points if not @hasfinished
		return @points if @failure
		@points = {@endPos}
		current = @lastNode

		while current
			table.insert(@points, current\GetPos())
			current = current\GetFrom()
		
		table.insert(@points, @startPos)
		return @points
	
	Stop: =>
		return if not @working
		@working = false
		@stop = true
		@hasfinished = true
		hook.Remove 'Think', tostring(@)
		@callbackStop()
	
	OnSuccess: (node) =>
		@lastNode = node
		@working = false
		@success = true
		@hasfinished = true
		hook.Remove 'Think', tostring(@)
		@RecalcPath()
		@callbackSuccess()
	
	OnFailure: =>
		@working = false
		@failure = true
		@hasfinished = true
		hook.Remove 'Think', tostring(@)
		@callbackFail()

	Start: =>
		@lastNodeNav = navmesh.Find(@endPos, 1, 20, 20)[1]
		@firstNodeNav = navmesh.Find(@startPos, 1, 20, 20)[1]

		if not @lastNodeNav or not @firstNodeNav
			@OnFailure()
			return
		
		@working = true
		@iterations = 0
		@totalTime = 0
		newNode = AStarNode(@firstNodeNav, @startPos\DistToSqr(@firstNodeNav\GetCenter()), @endPos)
		@opened = {newNode}
		@database = {newNode}
		hook.Add 'Think', tostring(@), -> @ThinkHook()
	
	GetNearestNode: =>
		local current
		local min
		local index

		for i = 1, #@opened
			data = @opened[i]
			if not min or data.f < min
				min = data.f
				current = data
				index = i
		
		table.remove(@opened, index) if index
		table.insert(@closed, current) if current
		return current
	@OnError = (err) ->
		print '[DMaps AStarTracer ERROR]: ', err
		print debug.traceback()
	ThinkHook: =>
		status = xpcall(@Think, @@OnError, @)
		if not status
			@OnFailure()
	Think: =>
		if not @working
			hook.Remove 'Think', tostring(@)
			return
		
		if #@opened == 0
			@OnFailure()
			return
		
		if #@opened >= @nodesLimit
			@OnFailure()
			return
		
		calculationTime = 0

		for i = 1, @loopsPerIteration
			sTime = SysTime()
			@iterations += 1
			if @iterations > @limit
				@OnFailure()
				return
			
			nearest = @GetNearestNode()
			if not nearest break
			if nearest.nav == @lastNodeNav
				@OnSuccess(nearest)
				return

			for node in *nearest\GetAdjacentAreas()
				hitClosed = false
				for cl in *@closed
					if cl.nav == node
						hitClosed = true
						break
				if hitClosed continue

				nodeObject = @GetNode(node)

				if nodeObject
					dist = nodeObject\GetPos()\DistToSqr(nearest\GetPos())
					distG = nearest\GetG() + dist
					distG += dist * .75 if nodeObject\Underwater()
					if nodeObject\GetG() > distG
						nodeObject\SetG(distG)
						nodeObject\SetFrom(nearest)
				else
					nodeObject = AStarNode(node, nearest\GetG() + node\GetCenter()\DistToSqr(nearest\GetPos()), @endPos)
					nodeObject\SetFrom(nearest)
					@AddNode(nodeObject)
					table.insert(@opened, nodeObject)
			cTime = (SysTime() - sTime) * 1000
			calculationTime += cTime
			@totalTime += cTime
			if @totalTime >= @timeThersold
				@OnFailure()
				return
			if calculationTime >= @frameThersold
				break

DMaps.AStarTracer = AStarTracer
DMaps.AStarNode = AStarNode
