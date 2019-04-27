
-- Copyright (C) 2019 DBot

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

import NBT from DLib
import luatype from _G

class DTransitions.SerializerBase
	new: (saveInstance) =>
		@saveInstance = saveInstance

	Serialize: (ent) => error('Not implemented')

	DeserializePre: (tag) => error('Not implemented')
	DeserializeMiddle: (ent, tag) =>
	DeserializePost: (ent, tag) =>

	-- When saving
	Ask: (tag) =>

	-- When loading
	Tell: (tag) =>

	QuickSerializeObj: (tag, obj, struct) =>
		for row in *struct
			savename = row[3] or row[1]

			if getter = obj['Get' .. row[1]]
				val = getter(obj)
				if val ~= nil
					writer = row[2]

					if writer == 'Entity'
						if IsValid(val)
							val = @saveInstance\GetEntityID(val)
							tag\SetInt(savename, val)
					else
						tag['Set' .. row[2]](tag, savename, val)

	QuickDeserializeObj: (tag, obj, struct, allowEnts = false) =>
		for row in *struct
			savename = row[3] or row[1]

			if tag\HasTag(savename)
				if setter = obj['Set' .. row[1]]
					val = tag\GetTagValue(savename)
					val = val == 1 if row[2] == 'Bool'
					val = tag\GetVector(savename) if row[2] == 'Vector'
					val = tag\GetAngle(savename) if row[2] == 'Angle'

					if row[2] == 'Entity'
						if allowEnts
							ent = @saveInstance\GetEntity(val)
							if IsValid(ent)
								status, err = pcall(setter, obj, ent, unpack(row, 4))
								error('Setter ' .. row[1] .. ' failed: ' .. err) if not status
					else
						status, err = pcall(setter, obj, val, unpack(row, 4))
						error('Setter ' .. row[1] .. ' failed: ' .. err) if not status
