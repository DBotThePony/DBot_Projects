
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
