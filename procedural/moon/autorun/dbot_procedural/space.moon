
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

class SpaceState
    new: (precacheX = 10, precacheY = 10, precacheZ = 10, size = 1) =>
        size = math.floor(size)
        error('Size <= 0!') if size <= 0
        @states = {}
        for x = -precacheX, precacheX
            @states[x] = {}
            for y = -precacheY, precacheY
                @states[x][y] = {}
                for z = -precacheZ, precacheZ
                    @states[x][y][z] = {}
        @size = size
    
    IsPosFree: (x = 0, y = 0, z = 0) =>
        x = math.floor(x / @size)
        y = math.floor(y / @size)
        z = math.floor(z / @size)
        return true if not @states[x]
        return true if not @states[x][y]
        return true if not @states[x][y][z]
        return #@states[x][y][z] == 0
    
    PutVector: (pos = Vector(), id = 'generic') =>
        {:x, :y, :z} = pos
        @Put(x, y, z, id)
    
    Put: (x = 0, y = 0, z = 0, id = 'generic') =>
        x = math.floor(x / @size)
        y = math.floor(y / @size)
        z = math.floor(z / @size)
        @states[x] = @states[x] or {}
        @states[x][y] = @states[x][y] or {}
        @states[x][y][z] = @states[x][y][z] or {}
        for state in *@states[x][y][z]
            if state == id
                return false
        table.insert(@states[x][y][z], id)
        return true
    
    GenerateBox: (pos = Vector(), mins = Vector(), maxs = Vector()) =>
        output = {}
        {:x, :y, :z} = pos
        {x: minx, y: miny, z: minz} = mins
        {x: maxx, y: maxy, z: maxz} = maxs
        x = math.floor(x / @size)
        y = math.floor(y / @size)
        z = math.floor(z / @size)
        maxx = math.floor(maxx / @size)
        maxy = math.floor(maxy / @size)
        maxz = math.floor(maxz / @size)
        minx = math.floor(minx / @size)
        miny = math.floor(miny / @size)
        minz = math.floor(minz / @size)
        i = 1
        for tx = x + minx, x + maxx
            for ty = y + miny, y + maxy
                for tz = z + miny, z + maxz
                    output[i] = {tx, ty, tz}
                    i += 1
        return output

    PutBox: (pos = Vector(), mins = Vector(), maxs = Vector(), id = 'generic') =>
        for {x, y, z} in *@GenerateBox(pos, mins, maxs)
            @Put(tx, ty, tz, id)

    RemoveBox: (pos = Vector(), mins = Vector(), maxs = Vector(), id = 'generic') =>
        for {x, y, z} in *@GenerateBox(pos, mins, maxs)
            @Remove(tx, ty, tz, id)
    
    GetPos: (x = 0, y = 0, z = 0) =>
        x = math.floor(x / @size)
        y = math.floor(y / @size)
        z = math.floor(z / @size)
        return {} if not @states[x]
        return {} if not @states[x][y]
        return {} if not @states[x][y][z]
        return [val for val in *@states[x][y][z]]
    
    Remove: (x = 0, y = 0, z = 0, id = 'generic') =>
        x = math.floor(x / @size)
        y = math.floor(y / @size)
        z = math.floor(z / @size)
        return false if not @states[x]
        return false if not @states[x][y]
        return false if not @states[x][y][z]
        for i, state in pairs @states[x][y][z]
            if state == id
                table.remove(@states[x][y][z], i)
                return true
        return false

DProcedural.SpaceState = SpaceState
