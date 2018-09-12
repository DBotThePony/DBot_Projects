
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


local borders = {
	border = {
		{'ShowVisuals', 'boolean', 'true'},
		{'ShowVisualBorder', 'boolean', 'true'},
		{'ShowVisualVignette', 'boolean', 'true'},
		{'PlaySound', 'boolean', 'true'},
		{'AllowNoclip', 'boolean', 'true'},
		{'IsEnabled', 'boolean', 'true'},
		{'DrawIfCanPass', 'boolean', 'true'},
		mins = Vector(-100, -1, 0),
		maxs = Vector(100, 1, 200),
	},
}

local function newConf(base, name, values)
	local copy = table.qcopy(borders[base])

	if values then
		for i, value in ipairs(values) do
			local hit = false

			for i2, valueOld in ipairs(copy) do
				if valueOld[1] == value[1] then
					hit = true
					valueOld[3] = value[3]
					break
				end
			end

			if not hit then
				table.insert(copy, value)
			end
		end

		copy.mins = values.mins or copy.mins
		copy.maxs = values.maxs or copy.maxs
	end

	borders[name] = copy

	return copy
end

newConf('border', 'playerborder')
newConf('border', 'propborder')
newConf('border', 'vehicleborder')
newConf('border', 'weaponborder')

newConf('border', 'solidborder', {
	{'DrawInner', 'boolean', 'true'},
})

newConf('solidborder', 'teamborder', {
	{'Team', 'int', '1000'},
	{'DrawIfCanPass', 'boolean', 'false'},
	{'DrawInner', 'boolean', 'false'},
	mins = Vector(-100, -100, 0),
	maxs = Vector(100, 100, 200),
})

hook.Run('RegisterBorderData', newConf)

for id, data in pairs(borders) do
	for i, entry in ipairs(data) do
		local t = entry[2]
		if t == 'int' or t == 'integer' then
			entry.check = 'number'
			entry.check2 = 'int'

			function entry.nwread()
				return net.ReadUInt(64)
			end

			function entry.nwwrite(value)
				return net.WriteUInt(value, 64)
			end

			function entry.fix(value)
				return math.floor(tonumber(value or 0) or 0)
			end
		elseif t:startsWith('varchar') then
			entry.check = 'string'
			entry.check2 = 'string'
			entry.nwread = net.ReadString
			entry.newwrite = net.WriteString
			entry.fix = tostring
		elseif t == 'float' or t == 'decimal' or t == 'double' then
			entry.check = 'number'
			entry.check2 = 'float'
			entry.nwread = net.ReadDouble
			entry.nwwrite = net.WriteDouble
			entry.fix = tonumber
		elseif t == 'boolean' or t == 'bool' then
			entry.check = 'boolean'
			entry.check2 = 'boolean'
			entry.nwread = net.ReadBool
			entry.nwwrite = net.WriteBool
			entry.fix = tobool
		end

		entry.default = entry[3]
		entry.name = entry[1]
		entry.type = entry.check
		entry.sqltype = entry[2]
		entry.defaultLua = entry.fix(entry[3])
	end
end

_G.func_border_data_ref = borders
