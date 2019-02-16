

--
-- Copyright (C) 2017-2019 DBot

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


AddCSLuaFile()

ENT.Type = 'anim'
ENT.PrintName = 'Minicrit receiver'
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.Author = 'DBot'
ENT.RenderGroup = RENDERGROUP_OTHER

entMeta = FindMetaTable('Entity')
entMeta.IsMarkedForDeath = => @GetNWInt('DTF2.MarksForDeath') > 0

with ENT
	.SetupDataTables = =>
		@NetworkVar('Entity', 0, 'MarkOwner')

	.Initialize = =>
		@SetNoDraw(true)
		@SetNotSolid(true)
		return if CLIENT
		@markStart = CurTime()
		@duration = 4
		@markEnd = @markStart + 4
		@SetMoveType(MOVETYPE_NONE)

	.UpdateDuration = (newtime = 0) =>
		return if @markEnd - CurTime() > newtime
		@duration = newtime
		@markEnd = CurTime() + newtime

	.SetupOwner = (owner) =>
		@SetPos(owner\GetPos())
		return if owner == @GetOwner()
		if IsValid(@GetOwner())
			@GetOwner()\SetNWInt('DTF2.MarksForDeath', @GetOwner()\GetNWInt('DTF2.MarksForDeath') - 1)
		@SetOwner(owner)
		@SetParent(owner)
		owner\SetNWInt('DTF2.MarksForDeath', owner\GetNWInt('DTF2.MarksForDeath') + 1)

	.Think = =>
		return if CLIENT
		return @Remove() if @markEnd < CurTime()
		return @Remove() if not IsValid(@GetOwner())

	.OnRemove = =>
		owner = @GetOwner()
		return if not IsValid(owner)
		owner\SetNWInt('DTF2.MarksForDeath', owner\GetNWInt('DTF2.MarksForDeath') - 1)
	.Draw = => false
