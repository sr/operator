class GlobalDallas < PardotGlobalExternal
  self.abstract_class = true
  establish_connection :dallas_global
end
