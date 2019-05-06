
--
-- Copyright (C) 2017-2019 DBotThePony

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


entMeta = FindMetaTable('Entity')

EntityClass =
	GetTFOverheal: => math.max(@Health() - @GetMaxHealth(), 0)
	GetTFIsOverhealed: => @GetNWBool('DTF2.AffectOverlealing') and @GetTFOverheal() ~= 0

	GetTFIsOverhealed: (def = false) => @GetNWBool('DTF2.AffectOverlealing', def)
	GetTFAffectAsOverheal: (def = false) => @GetNWBool('DTF2.AffectOverlealing', def)
	GetTFAffectOverheal: (def = false) => @GetNWBool('DTF2.AffectOverlealing', def)
	-- GetTFOverheal: (def = false) => @GetNWBool('DTF2.AffectOverlealing', def)
	GetTFAffectedByOverheal: (def = false) => @GetNWBool('DTF2.AffectOverlealing', def)

entMeta[k] = v for k, v in pairs EntityClass
