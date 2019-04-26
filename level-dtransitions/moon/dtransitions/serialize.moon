
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

class DTransitions.SaveInstance
	new: =>
		@serializers = {}
		@RegisterSerializer(DTransitions.PlayerSerializer(@))
		@RegisterSerializer(DTransitions.PropSerializer(@))
		@RegisterSerializer(DTransitions.WeaponSerializer(@))

	RegisterSerializer: (serializer) =>
		table.insert(@serializers, serializer)
		return @

	SortSerializers: =>
		table.sort @serializers, (a, b) -> a\GetPriority() > b\GetPriority()

	GetEntityID: (ent) => ent\GetCreationID()
	GetEntity: (id) => NULL

	Serialize: =>
		@SortSerializers()

		tag = NBT.TagCompound()
		@nbttag = tag
		entList = tag\AddTagList('entities', NBT.TYPEID.TAG_Compound)

		for serializer in *@serializers
			serializer\Ask(tag)

		for ent in *ents.GetAll()
			for serializer in *@serializers
				if serializer\CanSerialize(ent)
					tag2 = serializer\Serialize(ent)
					if tag2
						entList\AddValue(tag2)
						tag2\SetString('__savename', serializer.__class.SAVENAME)
						tag2\SetInt('__creation_id', ent\GetCreationID())
					break

		buff = DLib.BytesBuffer()
		tag\WriteFile(buff)

		fstream = file.Open('savetest.dat', 'wb', 'DATA')
		buff\ToFileStream(fstream)
		fstream\Close()
