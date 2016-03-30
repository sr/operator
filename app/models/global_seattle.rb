class GlobalSeattle < PardotGlobalExternal
  self.abstract_class = true
  establish_connection :seattle_global
end
