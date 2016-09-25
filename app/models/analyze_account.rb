class AnalyzeAccount
  INVESTMENT_OPTIONS = {
    "Investment_1"=>{"rate"=>"5", "min_tenure_months"=>"12", "institute_name"=>"ABC Bank", "risk"=>"1"},
    "Investment_2"=>{"rate"=>"10", "min_tenure_months"=>"6", "institute_name"=>"ABC Bank", "risk"=>"2"}
    "Investment_3"=>{"rate"=>"5", "min_tenure_months"=>"3", "institute_name"=>"ABC Bank", "risk"=>"3"}
    "Investment_4"=>{"rate"=>"10", "min_tenure_months"=>"1", "institute_name"=>"ABC Bank", "risk"=>"5"}
    "Investment_5"=>{"rate"=>"10", "min_tenure_months"=>"12", "institute_name"=>"ABC Bank", "risk"=>"3"}
   }

   DEBIT_AREAS = ["F&B", "Utilities", "Petrol", "Movies", "Transfers", "Stocks"]

  def get_account_ids(phone_no)
    cust_info = get_customer_info(phone_no)
    account_nos_hash = {}
    if !cust_info.blank?
      accounts_list = cust_info["accountList"]
      accounts_list.each do |account|
        account_nos_hash[account["id"]] = account["accountNo"]
      end
    end
    return account_nos_hash
  end

  def get_transaction_summary_for_customer(phone_no)
    transaction_summary = {}
    account_nos_hash = get_account_ids(phone_no)
    account_ids = account_nos_hash.keys
    if account_ids.size > 0
      all_transactions = get_all_transactions(account_ids)
      all_transactions.each do |account_id,transactions|
        transaction_summary[account_nos_hash[account_id]] = {}
        transactions.each do |transaction|
          tdate = Date.strptime(transaction["created"],"%m-%d-%Y").strftime("%B %Y")
          transaction_summary[account_nos_hash[account_id]][tdate] = Hash.new { |h, k| h[k] = 0.0 }
        end
        transaction_summary[account_nos_hash[account_id]].keys.each do |tdate|
          in_amount = 0.0
          out_amount = 0.0
          transactions.each do |transaction|
            if Date.strptime(transaction["created"],"%m-%d-%Y").strftime("%B %Y") == tdate 
              in_amount+= transaction["amount"]["moneyIn"].to_f
              out_amount+= transaction["amount"]["moneyOut"].to_f
            end
          end
          transaction_summary[account_nos_hash[account_id]][tdate]["in"] = in_amount
          transaction_summary[account_nos_hash[account_id]][tdate]["out"] = out_amount
          if in_amount < out_amount
            transaction_summary[account_nos_hash[account_id]][tdate]["savings"] = 0.0
          else
            transaction_summary[account_nos_hash[account_id]][tdate]["savings"] = in_amount - out_amount
          end
        end
      end
    end
    return transaction_summary
  end

  def get_max_spends(phone_no)
    top_trans = {}
    all_trans = {}
    account_nos_hash = get_account_ids(phone_no)
    if !account_nos_hash.blank?
      all_transactions = get_all_transactions(account_nos_hash.keys)
      all_transactions.each do |account_id,transactions|
        all_trans[account_nos_hash[account_id]] = Hash.new { |h, k| h[k] = 0.0 }
        transactions.each do |transaction|
          amount = transaction["amount"]["moneyOut"].to_f
          if amount > 0.0
            all_trans[account_nos_hash[account_id]][transaction["paymentDescriptor"]["name"]] += amount
          end
        end
      end
    end
    all_trans.each do |k,v|
      top_trans[k] = v.sort_by(&:last).to_h
    end
    return top_trans
  end

  def get_customer_info(phone_no)
    response = Barclay::V1.customers
    customers = response.parsed_response
    customer_info = customers.select {|customer| customer["mobileNo"] == phone_no}.last rescue nil
  end

  def get_all_transactions(account_ids)
    transaction_info = {}
    account_ids.each do |account_id|
      api_resp = Barclay::V1.transactions(account_id)
      transactions = api_resp.parsed_response
      transaction_info[account_id] = transactions
    end
    return transaction_info
  end

  

  def get_account_balances(phone_no)
    cust_info = get_customer_info(phone_no)
    balance_hash = {}
    if !cust_info.blank?
      accounts_list = cust_info["accountList"]
      accounts_list.each do |account|
        balance_hash[account["accountNo"]] = account["cuurentBalance"]
      end
    end
    return balance_hash
  end

end
