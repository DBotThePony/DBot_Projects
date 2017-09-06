AddCSLuaFile()
ENT.Type = 'anim'
ENT.PrintName = 'SCP-018'
ENT.Author = 'DBot'
ENT.Category = 'SCP Insanity'
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.AdminOnly = true
ENT.SetupDataTables = function(self)
  return self:NetworkVar('Vector', 0, 'BallColor', {
    KeyName = 'ballcolor',
    Edit = {
      type = 'VectorColor',
      order = 1
    }
  })
end
