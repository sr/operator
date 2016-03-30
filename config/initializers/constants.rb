if Rails.env.test?
  ENV['DB_D_GLOBAL'] = "global_test"
  ENV['DB_D_SHARD1'] = "shard1_test"
  ENV['DB_D_SHARD2'] = "shard2_test"
  ENV['DB_S_GLOBAL'] = "global_test"
  ENV['DB_S_SHARD1'] = "shard1_test"
  ENV['DB_S_SHARD2'] = "shard2_test"
else
  ENV['DB_D_GLOBAL'] = 'mysql2://pardot:pardot@localhost:3306/pardot_global'
  ENV['DB_D_SHARD1'] = 'mysql2://pardot:pardot@localhost:3306/pardot_shard1'
  ENV['DB_D_SHARD2'] = 'mysql2://pardot:pardot@localhost:3306/pardot_shard2'
  ENV['DB_S_GLOBAL'] = 'mysql2://pardot:pardot@localhost:3306/pardot_global'
  ENV['DB_S_SHARD1'] = 'mysql2://pardot:pardot@localhost:3306/pardot_shard1'
  ENV['DB_S_SHARD2'] = 'mysql2://pardot:pardot@localhost:3306/pardot_shard2'
end
