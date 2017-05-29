include('shared.lua')
ENT.Initialize = function(self)
  return self.BaseClass.Initialize(self)
end
ENT.Think = function(self)
  return self.BaseClass.Think(self)
end
ENT.Draw = function(self)
  return self.BaseClass.Draw(self)
end
