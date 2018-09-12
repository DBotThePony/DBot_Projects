
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

DTF2.PDA_CONSUMES_METAL = CreateConVar('tf_buildpda_consumes_metal', '1', {FCVAR_REPLICARED, FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Whatever building buildables using PDA consumes metal')
DTF2.PDA_COST_SENTRY = CreateConVar('tf_cost_sentry', '130', {FCVAR_REPLICARED, FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Sentry build cost')
DTF2.PDA_COST_DISPENSER = CreateConVar('tf_cost_dispenser', '100', {FCVAR_REPLICARED, FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Dispenser build cost')
DTF2.PDA_COST_TELE_IN = CreateConVar('tf_cost_tele_in', '50', {FCVAR_REPLICARED, FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Teleport entrance build cost')
DTF2.PDA_COST_TELE_OUT = CreateConVar('tf_cost_tele_out', '50', {FCVAR_REPLICARED, FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Teleport exit build cost')

entMeta = FindMetaTable('Player')

PlayerClass =
	GetBuildedSentry: => @GetNWEntity('DTF2.Sentry')
	GetBuildedDispenser: => @GetNWEntity('DTF2.Dispenser')
	GetBuildedTeleporterIn: => @GetNWEntity('DTF2.TeleporterIn')
	GetBuildedTeleporterOut: => @GetNWEntity('DTF2.TeleporterOut')
	
	SetBuildedSentry: (val = NULL) => @SetNWEntity('DTF2.Sentry', val)
	SetBuildedDispenser: (val = NULL) => @SetNWEntity('DTF2.Dispenser', val)
	SetBuildedTeleporterIn: (val = NULL) => @SetNWEntity('DTF2.TeleporterIn', val)
	SetBuildedTeleporterOut: (val = NULL) => @SetNWEntity('DTF2.TeleporterOut', val)

entMeta[k] = v for k, v in pairs PlayerClass

if SERVER
	func = (soundPlay) ->
		return (isSilent = false) =>
			return if isSilent
			ply = @GetTFPlayer()
			-- if IsValid(ply) and ply\IsPlayer()
			if IsValid(ply)
				ply.__DTF2_LastPlayedDestryReplic = ply.__DTF2_LastPlayedDestryReplic or 0
				time = CurTime()
				if ply.__DTF2_LastPlayedDestryReplic < time
					ply.__DTF2_LastPlayedDestryReplic = time + 1.5
					ply\EmitSound(soundPlay, 70, 100, 1, CHAN_VOICE)
	
	hook.Add 'TF2SentryDestroyed', 'PlayReplics', func('vo/engineer_autodestroyedsentry01.mp3')
	hook.Add 'TF2DispenserDestroyed', 'PlayReplics', func('vo/engineer_autodestroyeddispenser01.mp3')
	hook.Add 'TF2TeleporterDestroyed', 'PlayReplics', func('vo/engineer_autodestroyedteleporter01.mp3')
