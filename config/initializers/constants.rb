if Rails.env.test?
  ENV['DB_D_GLOBAL'] = "global_test"
  ENV['DB_D_SHARD1'] = "shard1_test"
  ENV['DB_D_SHARD2'] = "shard2_test"
  ENV['DB_S_GLOBAL'] = 'sqlite3://db/pardot_global.sqlite3'
  ENV['DB_S_SHARD1'] = 'sqlite3://db/pardot_shard1.sqlite3'
  ENV['DB_S_SHARD2'] = 'sqlite3://db/pardot_shard2.sqlite3'
else
  ENV['DB_D_GLOBAL'] = 'mysql2://pardot:pardot@localhost:3306/pardot_global'
  ENV['DB_D_SHARD1'] = 'mysql2://pardot:pardot@localhost:3306/pardot_shard1'
  ENV['DB_D_SHARD2'] = 'mysql2://pardot:pardot@localhost:3306/pardot_shard2'
  ENV['DB_S_GLOBAL'] = 'mysql2://pardot:pardot@localhost:3306/pardot_global'
  ENV['DB_S_SHARD1'] = 'mysql2://pardot:pardot@localhost:3306/pardot_shard1'
  ENV['DB_S_SHARD2'] = 'mysql2://pardot:pardot@localhost:3306/pardot_shard2'
end

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
