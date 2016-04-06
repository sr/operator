class AccountAccess < GlobalDallas
  self.table_name = 'global_account_access'
  belongs_to :account
end
