class GlobalDallas < PardotGlobalExternal
  self.abstract_class = true
  establish_connection ENV['DB_D_GLOBAL'].to_sym
end
