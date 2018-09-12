
--
-- Copyright (C) 2017-2018 DBot

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


export DTF2
DTF2 = DTF2 or {}

entMeta = FindMetaTable('Entity')

EntityClass =
	CritBoosted: => @GetNWBool('DTF2.CritBoosted')
	IsCritBoosted: => @GetNWBool('DTF2.CritBoosted')
	GetCritBoosted: => @GetNWBool('DTF2.CritBoosted')
	SetCritBoosted: (val = @CritBoosted()) => @SetNWBool('DTF2.CritBoosted', val)

	MiniCritBoosted: => @GetNWBool('DTF2.MiniCritBoosted')
	IsMiniCritBoosted: => @GetNWBool('DTF2.MiniCritBoosted')
	GetMiniCritBoosted: => @GetNWBool('DTF2.MiniCritBoosted')
	SetMiniCritBoosted: (val = @MiniCritBoosted()) => @SetNWBool('DTF2.MiniCritBoosted', val)

	GetCritModifier: => @CritBoosted() and 3 or @MiniCritBoosted() and 1.3 or 1

	GetMiniCritBuffers: => @GetNWInt('DTF2.MiniCritBuffers')
	SetMiniCritBuffers: (val = @GetMiniCritBuffers()) => @SetNWInt('DTF2.MiniCritBuffers', val)
	AddMiniCritBuffer: => @SetNWInt('DTF2.MiniCritBuffers', @GetMiniCritBuffers() + 1)
	RemoveMiniCritBuffer: => @SetNWInt('DTF2.MiniCritBuffers', @GetMiniCritBuffers() - 1)
	UpdateMiniCritBuffers: => @SetMiniCritBoosted(@GetNWInt('DTF2.MiniCritBuffers') > 0)

entMeta[k] = v for k, v in pairs EntityClass

if SERVER
	hook.Add 'PlayerSpawn', 'DTF2.Crits', =>
		@SetCritBoosted(false)
		@SetMiniCritBoosted(false)
