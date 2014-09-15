ENV['DB_D_GLOBAL'] = 'mysql2://pardot:pardot@localhost:3306/pardot_global'
ENV['DB_D_SHARD1'] = 'mysql2://pardot:pardot@localhost:3306/pardot_shard1'
ENV['DB_D_SHARD2'] = 'mysql2://pardot:pardot@localhost:3306/pardot_shard2'
ENV['DB_S_GLOBAL'] = 'mysql2://pardot:pardot@localhost:3306/pardot_global'
ENV['DB_S_SHARD1'] = 'mysql2://pardot:pardot@localhost:3306/pardot_shard1'
ENV['DB_S_SHARD2'] = 'mysql2://pardot:pardot@localhost:3306/pardot_shard2'

# Database
class DB
  Account = "Account"
  Global = "Global"
end

# View
class VW
  SQL = "SQL"
  UI = "UI"
  CSV = "CSV" #for CSV output
end

# Datacenter
class DC
  Dallas = "Dallas"
  Seattle = "Seattle"
end
