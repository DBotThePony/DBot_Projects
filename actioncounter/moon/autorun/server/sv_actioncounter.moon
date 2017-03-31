
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

util.AddNetworkString 'dactioncounter_network'

NetworkedValues = {
	{'jump', 4}
	{'speed', 400}
	{'duck', 200}
	{'walk', 200}
	{'water', 400}
	{'uwater', 400}
	{'fall', 100}
	{'climb', 100}
}

PlayerCache = {}
LastThink = CurTime!

Think = ->
	cTime = CurTime!
	delta = LastThink - cTime
	LastThink = cTime
	
	for ply in *player.GetAll()
		i = ply\EntIndex()
		PlayerCache[i] = PlayerCache[i] or {}
		self = PlayerCache[i]
		
		@jump_cnt = @jump_cnt or 0
		@speed_cnt = @speed_cnt or 0
		@duck_cnt = @duck_cnt or 0
		@walk_cnt = @walk_cnt or 0
		@water_cnt = @water_cnt or 0
		@uwater_cnt = @uwater_cnt or 0
		@fall_cnt = @fall_cnt or 0
		@climb_cnt = @climb_cnt or 0
		
		for nData in *NetworkedValues
			@[nData[1] .. '_timer'] = @[nData[1] .. '_timer'] or cTime
		
		if @jump_timer < cTime and not @jump
			@jump_cnt = 0
		
		onGround = ply\OnGround!
		pos = ply\GetPos!
		lastPos = @pos or pos
		@pos = pos
		
		speed = pos\Distance(lastPos)
		deltaZ = pos.z - lastPos.z
		
		waterLevel = ply\WaterLevel!
		inVehicle = ply\InVehicle!
		
		shift = ply\KeyDown(IN_SPEED)
		walk = ply\KeyDown(IN_WALK)
		duck = ply\KeyDown(IN_DUCK)
		
		if inVehicle
			vehicle = ply\GetVehicle!
			waterLevel = vehicle\WaterLevel!
			shift = false
			walk = false
			jump = false
			duck = false
		
		inWater = waterLevel > 0
		underWater = waterLevel >= 3
		
		if not onGround and ply\GetMoveType! == MOVETYPE_WALK
			if deltaZ > 0
				@climb_cnt += deltaZ
			else
				@fall_cnt -= deltaZ
		else
			@climb_cnt = 0
			@fall_cnt = 0
		
		if not onGround or speed < 0.5 or inWater
			if @duck_timer < cTime then @duck_cnt = 0
			if @speed_timer < cTime then @speed_cnt = 0
			if @walk_timer < cTime then @walk_cnt = 0
		else
			if duck
				@duck_cnt += speed
				@duck_timer = cTime + 1
			elseif walk
				@walk_cnt += speed
				@walk_timer = cTime + 1
			elseif shift
				@speed_cnt += speed
				@speed_timer = cTime + 1
		
		if not inWater
			if @water_timer < cTime then @water_cnt = 0
			if @uwater_timer < cTime then @uwater_cnt = 0
			
			if not onGround and not @jump
				@jump = true
				@jump_cnt += 1
				@jump_timer = cTime + 4
			elseif onGround and @jump
				@jump = false
				@jump_timer = cTime + 4
		else
			if underWater 
				@uwater_cnt += speed
				@uwater_timer = cTime + 1
			else
				@water_cnt += speed
				@water_timer = cTime + 1
			
			if @jump
				@jump = false
				@jump_timer = cTime + 4
		
		nwhit = false
		
		for nData in *NetworkedValues
			if @[nData[1] .. '_cnt'] ~= @[nData[1] .. '_ncnt'] and @[nData[1] .. '_cnt'] >= nData[2]
				nwhit = true
				break
		
		if nwhit
			net.Start('dactioncounter_network')
			
			for nData in *NetworkedValues
				if @[nData[1] .. '_cnt'] >= nData[2]
					net.WriteUInt(@[nData[1] .. '_cnt'], 32)
					@[nData[1] .. '_ncnt'] = @[nData[1] .. '_cnt']
				else
					net.WriteUInt(0, 32)
			
			net.Send(ply)

hook.Add('Think', 'DActionCounter', Think)
