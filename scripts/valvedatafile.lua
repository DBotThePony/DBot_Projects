
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

local assert = assert
local table = table
local type = type
local pairs = pairs
local print = print
local error = error
local string = string

local function decode(lines)
	assert(type(tableIn) == 'lines', 'Invalid argument passed: ' .. type(lines) .. '. You must pass array containing file\'s lines')
	local construct = {}
	local currentData = construct
	local literalName
	local stack = {construct}
	local i = 0

	for line in ipairs(lines) do
		if #stack == 0 then
			error('data stack got empty (after line' .. i .. ')')
		end

		i = i + 1
		local trim = line:match('^%s*(.-)%s*$')

		if trim:find('//') then
			trim = trim:gsub('%s*//.*$', '')
		end

		if trim == '' or trim:sub(1, 2) == '//' then

		elseif trim:sub(1, 1) == '"' then
			assert(trim:sub(#trim) == '"', 'malformed name token/key-value pair at line ' .. i)

			local key, value = '', ''
			local atKey, keyFinished, atValue, valueFinished = false, false, false

			for char in trim:gmatch('.') do
				if char == '"' then
					if valueFinished and keyFinished then
						print('VDF: extra (junk) data at line ' .. i)
						break
					end

					if atKey then
						atKey = false
						keyFinished = true
					elseif atValue then
						atValue = false
						valueFinished = true
					else
						if keyFinished then
							atValue = true
						elseif valueFinished then
							error('malformed data at line ' .. i .. ' - extra quote pointing at unknown data')
						else
							atKey = true
						end
					end
				elseif char == ' ' then
					if atKey then
						key = key .. ' '
					elseif atValue then
						value = value .. ' '
					end
				elseif char == '\t' then
					if atKey then
						key = key .. '\t'
					elseif atValue then
						value = value .. '\t'
					end
				else
					if atKey then
						key = key .. char
					elseif atValue then
						value = value .. char
					else
						error('malformed key-value pair/header at line ' .. i)
					end
				end
			end

			if valueFinished then
				if currentData[key] == nil then
					currentData[key] = value
				elseif type(currentData[key]) ~= 'table' then
					local val = currentData[key]
					currentData[key] = {}
					table.insert(currentData[key], value)
					table.insert(currentData[key], val)
				else
					table.insert(currentData[key], value)
				end
			elseif keyFinished then
				literalName = key
			else
				error('unable to parse line ' .. i)
			end
		elseif trim == '{' then
			assert(literalName, 'creating a table without name at line ' .. i)
			table.insert(stack, currentData)
			currentData = {}
			stack[#stack][literalName] = currentData
		elseif trim == '}' then
			currentData = table.remove(stack)
			literalName = nil
		else
			print('-----------')
			print(trim)
			print('-----------')
			error('junk data at line ' .. i .. '.')
		end
	end

	assert(#stack == 1, 'stack size after parse finish is not 1! ' .. #stack)

	return construct
end

local getmetatable = getmetatable
local lines, level

local function tabs()
	return string.rep('\t', level)
end

local function spaces(len)
	return string.rep(' ', 22 - len)
end

local function supportsToVDF(object)
	return object:GetVDFValue()
end

local function diveInto(name, tableIn, explicitString)
	assert(type(name) == 'string', 'key-value table name must be a string. ' .. type(name))

	table.insert(lines, string.format('%s%q\n%s{', tabs(), name, tabs()))
	level = level + 1

	for key, value in pairs(tableIn) do
		assert(type(key) == 'string' or type(key) == 'number', 'Table index must be string (or a number)! ' .. type(key) .. ' (' .. tostring(key) .. ')')
		local key2 = tostring(key)

		local valtype = type(value)

		if valtype == 'string' or valtype == 'number' then
			table.insert(lines, string.format('%s%q%s%q', tabs(), key2, spaces(#key2), tostring(value)))
		elseif valtype == 'boolean' then
			table.insert(lines, string.format('%s%q%s%q', tabs(), key2, spaces(#key2), value and '1' or '0'))
		elseif valtype == 'table' then
			diveInto(key2, value, explicitString)
		else
			local meta = getmetatable(value)

			if type(meta) == 'table' and meta.__tostring then
				table.insert(lines, string.format('%s%q%s%q', tabs(), key2, spaces(#key2), tostring(value)))
			else
				local status, value2 = pcall(supportsToVDF, value)

				if status and type(value2) == 'string' then
					table.insert(lines, string.format('%s%q%s%q', tabs(), key2, spaces(#key2), value2))
				elseif explicitString then
					table.insert(lines, string.format('%s%q%s%q', tabs(), key2, spaces(#key2), tostring(value)))
				else
					error('Value of type ' .. type(value) .. ' does not support either __tostring metamethod and does not have :GetVDFValue() method and explicitString flag is false! To force write of this, use `true` as third argument to encoder')
				end
			end
		end
	end

	level = level - 1
	table.insert(lines, string.format('%s}', tabs()))
end

local function encode(name, tableIn, explicitString)
	assert(type(name) == 'string', 'There must be a valid name (for file\'s top header) ' .. type(name))
	assert(type(tableIn) == 'table', 'Invalid argument passed: ' .. type(tableIn))

	lines = {}
	level = 0

	diveInto(name, tableIn, explicitString)

	return lines
end

return {decode, encode}