
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

class DungeonMainRoom extends DProcedural.BasicRoom
    new: (...) => super(...)

class DungeonGeneratorController
    @GRID_SIZE = 700
    new: (seed = math.random(1, 1000), pos = Vector(), skin = DProcedural.BuildingSkin(@)) =>
        @seed = seed
        @skin = skin
        @random = DProcedural.Random(@seed)
        @rooms = {}
        @roomsID = {}
        @pos = pos
        @CPPIOwner = NULL
        @entities = {}
        @roomsSpace = {}
        @connections = {}
        @connectionsArray = {}

        @AddRoom(DungeonMainRoom())

        @AddRoom(DProcedural.BasicRoom(), Vector(0, 1, 0))
        @AddRoom(DProcedural.BasicRoom(), Vector(1, 0, 0))
        @AddRoom(DProcedural.BasicRoom(), Vector(-1, 0, 0))
        @AddRoom(DProcedural.BasicRoom(), Vector(0, -1, 0))

        @CreateConnection(Vector(0, 0, 0), Vector(0, 1, 0))
        @CreateConnection(Vector(0, 0, 0), Vector(0, -1, 0))
        @CreateConnection(Vector(0, 0, 0), Vector(1, 0, 0))
        @CreateConnection(Vector(0, 0, 0), Vector(-1, 0, 0))
    
    Remove: =>
        for ent in *@entities
            ent\Remove() if IsValid(ent)
        @entities = {}
    
    AddRoom: (room, position = Vector(0, 0, 0)) =>
        return if @roomsID[room\GetID()]
        table.insert(@rooms, room)
        @roomsID[room\GetID()] = room
        room\SetSkin(@skin)
        room\SetPos(@pos, false)
        {:x, :y, :z} = position
        @roomsSpace[x] = @roomsSpace[x] or {}
        @roomsSpace[x][y] = @roomsSpace[x][y] or {}
        @roomsSpace[x][y][z] = room
        room\SetRelativePos(position * @@GRID_SIZE, false)
        room\UpdatePos()
        room.dungeonPos = position
    
    GetConnectedRooms: => [{r1, r2, sum, ang} for {r1, r2, sum, ang} in *@connectionsArray]
    CreateConnection: (first = Vector(), second = Vector()) =>
        return false if first.z ~= second.z
        sum = first - second
        return false if sum\Length() ~= 1
        sum2 = second - first
        return false if first == second
        {:x, :y, :z} = first
        return false if not @roomsSpace[x]
        return false if not @roomsSpace[x][y]
        return false if not @roomsSpace[x][y][z]
        firstRoom = @roomsSpace[x][y][z]
        {:x, :y, :z} = second
        return false if not @roomsSpace[x]
        return false if not @roomsSpace[x][y]
        return false if not @roomsSpace[x][y][z]
        secondRoom = @roomsSpace[x][y][z]
        @connections[firstRoom\GetID()] = @connections[firstRoom\GetID()] or {}
        @connections[secondRoom\GetID()] = @connections[secondRoom\GetID()] or {}
        return false if @connections[firstRoom\GetID()][secondRoom\GetID()]
        return false if @connections[secondRoom\GetID()][firstRoom\GetID()]
        @connections[firstRoom\GetID()][secondRoom\GetID()] = true
        @connections[secondRoom\GetID()][firstRoom\GetID()] = true
        table.insert(@connectionsArray, {firstRoom, secondRoom, sum, sum\Angle()})
        firstRoom\SetSideOpen(DProcedural.GetSideByVector(sum2), true)
        secondRoom\SetSideOpen(DProcedural.GetSideByVector(sum), true)
        return true
    SetOwner: (val = NULL) =>
        @CPPIOwner = val
        for room in *@rooms
            room\SetOwner(val)
    GetOwner: => @CPPIOwner

    @CORRIDOR_STRUCTURE = {
        {
            'model': 'models/hunter/plates/plate3x8.mdl'
            'position': Vector(95 / 2, 195 / 2, 0)
            'angle': Angle(0, 0, 0)
        }

        {
            'model': 'models/hunter/plates/plate3x8.mdl'
            'position': Vector(95 / 2, 190 / 2, 190)
            'angle': Angle(0, 0, 0)
        }
    }
    
    Spawn: =>
        for room in *@rooms
            room\SpawnInWorld(@entities)
        for {r1, r2, sum, ang} in *@connectionsArray
            for {:model, :position, :angle} in *@@CORRIDOR_STRUCTURE
                newAng = Angle(angle.p + ang.p, angle.y + ang.y, angle.r + ang.r)
                newPos = Vector(position + sum)
                newPos\Rotate(ang)
                newEnt = ents.Create('prop_physics')
                table.insert(@entities, newEnt)
                with newEnt
                    \SetModel(model)
                    \SetPos(@pos + newPos)
                    \SetAngles(newAng)
                    \Spawn()
                    \Activate()
                    \GetPhysicsObject()\EnableMotion(false)
        return @entities
    
    SetSeed: (val = @seed) =>
        @random\SetSeed(val)
        @seed = val

    GetSeed: => @seed
    GetSkin: => @skin

DProcedural.Generator = DungeonGeneratorController
