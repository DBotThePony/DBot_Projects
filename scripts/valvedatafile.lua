
-- Copyright (C) 2018-2019 DBot

-- Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
-- files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,
-- modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software
-- is furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
-- OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
-- LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
-- CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

local assert = assert
local table = table
local type = type
local pairs = pairs
local print = print
local error = error
local string = string

local function nextCondition(line)
	local lastPos = 1
	local valid = true
	local lastbor = true

	return function()
		local findStart1, findEnd1 = string.find(line, '||', lastPos, true)
		local findStart2, findEnd2 = string.find(line, '&&', lastPos, true)
		local findStart, findEnd
		local bor = true

		if findStart2 and (not findStart1 or findStart2 < findStart1) then
			bor = false
			findStart, findEnd = findStart2, findEnd2
		elseif findStart1 and (not findStart2 or findStart1 < findStart2) then
			findStart, findEnd = findStart1, findEnd1
		end

		if not findStart then
			if not valid then return end
			valid = false
			return lastbor, string.sub(line, lastPos):match('^%s*(.-)%s*$'), true
		end

		lastbor = bor

		local str = string.sub(line, lastPos, findStart - 1):match('^%s*(.-)%s*$')
		lastPos = findEnd + 1

		return bor, str, false
	end
end

local function decode(lines, isPC, isWindows, isOSX, isLinux, isPOSIX, isXBox)
	if isPC == nil then isPC = true end
	if isWindows == nil then isWindows = true end
	if isOSX == nil then isOSX = false end
	if isLinux == nil then isLinux = false end
	if isPOSIX == nil then isPOSIX = false end
	if isXBox == nil then isXBox = false end

	assert(type(lines) == 'table', 'Invalid argument passed: ' .. type(lines) .. '. You must pass array containing file\'s lines')
	local construct = {}
	local currentData = construct
	local literalName
	local stack = {construct}

	for i, line in ipairs(lines) do
		if #stack == 0 then
			error('data stack got empty (after line' .. i .. ')')
		end

		local trim = line:match('^%s*(.-)%s*$')

		if trim:find('//') then
			trim = trim:gsub('%s*//.*$', '')
		end

		local condition = trim ~= '' and trim:sub(1, 2) ~= '//'
		local conditional = false

		if condition and trim:sub(#trim) == ']' then
			condition = false
			conditional = true
			local startpos

			for seek = #trim, 1, -1 do
				if trim:sub(seek, seek) == '[' then
					startpos = seek
					break
				end
			end

			if not startpos then
				error('expected opening ([) conditional token at line ' .. i .. ' but none found')
			end

			local conditions = {}
			local prevCond

			for bor, conditionStr, ending in nextCondition(trim:sub(startpos + 1, #trim - 1)) do
				local bNot = false

				if conditionStr:sub(1, 1) == '!' then
					bNot = true
					conditionStr = conditionStr:sub(2)
				end

				local elevate = false

				if conditionStr == '$X360' then
					elevate = isXBox
				elseif conditionStr == '$WIN32' then
					elevate = isPC
				elseif conditionStr == '$WINDOWS' then
					elevate = isWindows
				elseif conditionStr == '$OSX' then
					elevate = isOSX
				elseif conditionStr == '$LINUX' then
					elevate = isLinux
				elseif conditionStr == '$POSIX' then
					elevate = isPOSIX
				end

				if bNot then
					elevate = not elevate
				end

				if prevCond ~= nil then
					elevate = elevate and prevCond
					prevCond = nil
				end

				if not bor and not ending then
					prevCond = elevate
				else
					table.insert(conditions, elevate)
				end
			end

			if prevCond ~= nil then
				error('malformed condition at line ' .. i)
			end

			for i, cond in ipairs(conditions) do
				condition = condition or cond
			end

			trim = trim:sub(1, startpos - 1):match('^%s*(.-)%s*$')
		end

		if not condition then

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
				if currentData[key] == nil or conditional then
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
