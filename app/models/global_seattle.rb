class GlobalSeattle < PardotGlobalExternal
  self.abstract_class = true
  establish_connection ENV['DB_S_GLOBAL']
end
