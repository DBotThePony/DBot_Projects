AddCSLuaFile()
ENT.Type = 'anim'
ENT.PrintName = 'SCP-173'
ENT.Author = 'DBot'
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.AdminOnly = true
ENT.Category = 'DBot'
ENT.IsSCP173 = true
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.SetupDataTables = function(self)
  self:NetworkVar('Int', 0, 'Frags')
  return self:NetworkVar('Int', 1, 'PFrags')
end
