module AccountsHelper
  def accounts_name_id_hash
    Hash[*@accounts.map{|account|[account.descriptive_name, account.id]}.unshift(["",""]).flatten]
  end
end
