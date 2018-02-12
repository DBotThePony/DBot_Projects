
-- Copyright (C) 2018 DBot

-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at

--     http://www.apache.org/licenses/LICENSE-2.0

-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

local borders = {
	border = {
		{'ShowVsials', 'boolean', 'true'},
		{'ShowVisualBorder', 'boolean', 'true'},
		{'ShowVisualVignette', 'boolean', 'true'},
		{'PlaySound', 'boolean', 'true'},
		{'AllowNoclip', 'boolean', 'true'},
		{'IsEnabled', 'boolean', 'true'},
		{'DrawIfCanPass', 'boolean', 'true'},
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
})

_G.func_border_data_ref = borders
