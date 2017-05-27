
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

class BasicRoom
    @MINS = Vector(-190, -190, 0)
    @MAXS = Vector(190, 190, 190)

    @NORTH = Vector(0, 100, 0)
    @SOUTH = Vector(0, -100, 0)
    @WEST = Vector(-100, 0, 0)
    @EAST = Vector(100, 0, 0)

    @CEILING_MODEL = 'models/hunter/plates/plate8x8.mdl'
    @FLOOR_MODEL = 'models/hunter/plates/plate8x8.mdl'

    @NEXT_ROOM_ID = 0

    @ReplicateWallStructure: =>
        structure = @WALL_STRUCTURE[DProcedural.DIRECTION_NORTH]
        @WALL_STRUCTURE[DProcedural.DIRECTION_SOUTH] = for {:door, :pos, :ang, :model} in *structure
            {:x, :y, :z} = pos
            y = -y
            {:door, pos: Vector(x, y, z), :ang, :model}

        @WALL_STRUCTURE[DProcedural.DIRECTION_WEST] = for {:door, :pos, :ang, :model} in *structure
            newPos = Vector(pos)
            {:p, :y, :r} = ang
            newAng = Angle(p, y, r)
            newAng\RotateAroundAxis(newAng\Right(), 90)
            newPos\Rotate(newAng)
            newPos.x *= 2
            {:door, pos: newPos, ang: newAng, :model}

        @WALL_STRUCTURE[DProcedural.DIRECTION_EAST] = for {:door, :pos, :ang, :model} in *structure
            newPos = Vector(pos)
            {:p, :y, :r} = ang
            newAng = Angle(p, y, r)
            newAng\RotateAroundAxis(newAng\Right(), -90)
            newPos\Rotate(newAng)
            newPos.x *= 2
            {:door, pos: newPos, ang: newAng, :model}

    @WALL_STRUCTURE = {
        [DProcedural.DIRECTION_NORTH]: {
            {
                'door': false
                'pos': Vector(190 - 95 / 2, 190, 95)
                'ang': Angle(0, 180, 90)
                'model': 'models/hunter/plates/plate3x8.mdl'
            }

            {
                'door': false
                'pos': Vector(-190 + 95 / 2, 190, 95)
                'ang': Angle(0, 180, 90)
                'model': 'models/hunter/plates/plate3x8.mdl'
            }

            {
                'door': true
                'pos': Vector(0, 190, 95)
                'ang': Angle(0, 180, 90)
                'model': 'models/hunter/plates/plate3x8.mdl'
            }
        }
    }

    @ReplicateWallStructure()

    new: (pos = Vector(), closeN = true, closeS = true, closeW = true, closeE = true) =>
        @id = @@NEXT_ROOM_ID
        @@NEXT_ROOM_ID += 1
        @closeN = closeN
        @closeS = closeS
        @closeW = closeW
        @closeE = closeE
        @pos = pos
        @relativePos = Vector()
        @CPPIOwner = NULL
        @entities = {}
        @walls = {
            [DProcedural.DIRECTION_NORTH]: {}
            [DProcedural.DIRECTION_SOUTH]: {}
            [DProcedural.DIRECTION_WEST]: {}
            [DProcedural.DIRECTION_EAST]: {}
        }
    
    GetID: => @id
    SetPos: (pos = Vector(), update = true) =>
        @pos = pos
        @UpdatePos() if update
    SetRelativePos: (pos = Vector(), update = true) =>
        @relativePos = pos
        @UpdatePos() if update
    
    UpdatePos: =>
        @floorModel\SetPos(@pos + @floorModel.relativePos + @relativePos) if IsValid(@floorModel)
        @ceilingModel\SetMaterial(@pos + @ceilingModel.relativePos + @relativePos) if IsValid(@ceilingModel)
        wall\SetMaterial(wall.relativePos + @pos + @relativePos) for side, data in pairs @walls for wall in *data
    
    SetSkin: (skin) =>
        @skin = skin
        return if not skin
        @UpdateSkin()
    
    UpdateSkin: =>
        return if not @skin
        @floorModel\SetMaterial(@skin\GetFloor(@floorModel)) if IsValid(@floorModel)
        @ceilingModel\SetMaterial(@skin\GetCeiling(@ceilingModel)) if IsValid(@ceilingModel)
        wall\SetMaterial(@skin\GetWall(side, wall)) for side, data in pairs @walls for wall in *data

    SetOwner: (owner = NULL) =>
        @CPPIOwner = owner
        for ent in *@entities
            ent\CPPISetOwner(owner) if ent\IsValid() and ent.CPPISetOwner
    GetOwner: => @CPPIOwner
    
    IsNorthOpen: => not @closeN
    IsSouthOpen: => not @closeS
    IsEastOpen: => not @closeE
    IsWestOpen: => not @closeW
    IsSideClosed: (side = DProcedural.DIRECTION_NORTH) => not @IsSideOpen(side)
    IsSideOpen: (side = DProcedural.DIRECTION_NORTH) =>
        switch side
            when DProcedural.DIRECTION_NORTH then return not @closeN
            when DProcedural.DIRECTION_SOUTH then return not @closeS
            when DProcedural.DIRECTION_EAST then return not @closeE
            when DProcedural.DIRECTION_WEST then return not @closeW
        return false
    SetSideOpen: (side = DProcedural.DIRECTION_NORTH, status = false) =>
        switch side
            when DProcedural.DIRECTION_NORTH then @closeN = not status
            when DProcedural.DIRECTION_SOUTH then @closeS = not status
            when DProcedural.DIRECTION_EAST then @closeE = not status
            when DProcedural.DIRECTION_WEST then @closeW = not status
    
    UpdateOwner: =>
        for ent in *@entities
            ent\CPPISetOwner(@GetOwner()) if ent\IsValid() and ent.CPPISetOwner
    Remove: =>
        for ent in *@entities
            ent\Remove() if ent\IsValid()
        @entities = {}
    SpawnInWorld: (tableTarget) =>
        @floorModel = ents.Create('prop_physics')
        table.insert(tableTarget, @floorModel)
        table.insert(@entities, @floorModel)
        with @floorModel
            \SetMaterial(@skin\GetFloor(@floorModel)) if @skin
            \SetModel(@@FLOOR_MODEL)
            \SetPos(@pos + @relativePos)
            .relativePos = Vector()
            \Spawn()
            \Activate()
            \GetPhysicsObject()\EnableMotion(false)
        @ceilingModel = ents.Create('prop_physics')
        table.insert(tableTarget, @ceilingModel)
        table.insert(@entities, @ceilingModel)
        with @ceilingModel
            \SetMaterial(@skin\GetCeiling(@ceilingModel)) if @skin
            \SetModel(@@CEILING_MODEL)
            .relativePos = Vector(0, 0, @GetHeight())
            \SetPos(@pos + .relativePos + @relativePos)
            \Spawn()
            \Activate()
            \GetPhysicsObject()\EnableMotion(false)
        for direction, data in pairs @@WALL_STRUCTURE
            for {:door, :pos, :ang, :model} in *data
                continue if door and @IsSideOpen(direction)
                newEnt = ents.Create('prop_physics')
                table.insert(tableTarget, newEnt)
                table.insert(@entities, newEnt)
                with newEnt
                    \SetMaterial(@skin\GetWall(direction, newEnt)) if @skin
                    \SetModel(model)
                    .relativePos = pos
                    \SetPos(@pos + pos + @relativePos)
                    \SetAngles(ang)
                    \Spawn()
                    \Activate()
                    \GetPhysicsObject()\EnableMotion(false)
                table.insert(@walls[direction], newEnt) if @walls[direction]
        @UpdateOwner()
        timer.Simple 0, -> @UpdateSkin()

    GetMins: => @@MINS
    GetMaxs: => @@MAXS
    GetHeight: => @GetMaxs().z - @GetMins().z
    GetWest: => @@WEST
    GetEast: => @@EAST
    GetNorth: => @@NORTH
    GetSouth: => @@SOUTH

    GetSideAt: (side = DProcedural.DIRECTION_NORTH) =>
        switch side
            when DProcedural.DIRECTION_NORTH
                @GetNorth()
            when DProcedural.DIRECTION_SOUTH
                @GetSouth()
            when DProcedural.DIRECTION_EAST
                @GetEast()
            when DProcedural.DIRECTION_WEST
                @GetWest()
            else
                @GetNorth()

DProcedural.BasicRoom = BasicRoom
