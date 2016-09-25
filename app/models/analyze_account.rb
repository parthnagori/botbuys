class AnalyzeAccount
  INVESTMENT_OPTIONS = {"Investment_1"=>{"rate"=>"5", "min_tenure_months"=>"12", "institute_name"=>"ABC Bank", "risk"=>"1"}, "Investment_2"=>{"rate"=>"10", "min_tenure_months"=>"6", "institute_name"=>"ABC Bank", "risk"=>"2"}, "Investment_3"=>{"rate"=>"5", "min_tenure_months"=>"3", "institute_name"=>"ABC Bank", "risk"=>"3"}, "Investment_4"=>{"rate"=>"10", "min_tenure_months"=>"1", "institute_name"=>"ABC Bank", "risk"=>"5"},"Investment_5"=>{"rate"=>"10", "min_tenure_months"=>"12", "institute_name"=>"ABC Bank", "risk"=>"3"}
   }

   SAVINGS_INTEREST = 4.0

   DEBIT_AREAS = ["F&B", "Utilities", "Petrol", "Movies", "Transfers", "Stocks"]

  def self.get_account_ids(phone_no)
    cust_info = get_customer_info(phone_no)
    account_nos_hash = {}
    if !cust_info.blank?
      accounts_list = cust_info["accountList"]
      accounts_list.each do |account|
        if account["accountNo"].blank?
          account_nos_hash[account["id"]] = account["accountType"]+account["card"]["cardNumber"]
        else  
          account_nos_hash[account["id"]] = account["accountType"]+account["accountNo"]
        end
      end
    end
    return account_nos_hash
  end

  def self.get_transaction_summary_for_customer(phone_no)
    transaction_summary = {}
    sorted_transaction_summary = {}
    account_nos_hash = get_account_ids(phone_no)
    account_ids = account_nos_hash.keys
    if account_ids.size > 0
      all_transactions = get_all_transactions(account_ids)
      all_transactions.each do |account_id,transactions|
        transaction_summary[account_nos_hash[account_id]] = {}
        transactions.each do |transaction|
          tdate = Date.strptime(transaction["created"],"%m-%d-%Y").strftime("%b %Y")
          transaction_summary[account_nos_hash[account_id]][tdate] = Hash.new { |h, k| h[k] = 0.0 }
        end
        transaction_summary[account_nos_hash[account_id]].keys.each do |tdate|
          in_amount = 0.0
          out_amount = 0.0
          transactions.each do |transaction|
            if Date.strptime(transaction["created"],"%m-%d-%Y").strftime("%b %Y") == tdate 
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
    transaction_summary.each do |k,v|
      sorted_transaction_summary[k] = v.sort_by{|k,v| k.to_date}.to_h
    end
    return sorted_transaction_summary
  end

  def self.get_max_spends(phone_no)
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

  def self.get_customer_info(phone_no)
    response = Barclay::V1.customers
    customers = response.parsed_response
    customer_info = customers.select {|customer| customer["mobileNo"] == phone_no}.last rescue nil
  end

  def self.get_all_transactions(account_ids)
    transaction_info = {}
    account_ids.each do |account_id|
      api_resp = Barclay::V1.transactions(account_id)
      transactions = api_resp.parsed_response
      transaction_info[account_id] = transactions
    end
    return transaction_info
  end

  def self.get_account_balances(phone_no)
    cust_info = get_customer_info(phone_no)
    balance_hash = {}
    if !cust_info.blank?
      accounts_list = cust_info["accountList"]
      accounts_list.each do |account|
        if account["currentBalance"].blank?
          balance = 0.0
        else
          balance = account["currentBalance"]
        end
        if account["accountNo"].blank?
          balance_hash[account["accountType"]+account["card"]["cardNumber"]] = balance
        else  
          balance_hash[account["accountType"]+account["accountNo"]] = balance
        end
      end
    end
    return balance_hash
  end

  def self.get_account_types(phone_no)
    cust_info = get_customer_info(phone_no)
    actype_hash = {}
    if !cust_info.blank?
      accounts_list = cust_info["accountList"]
      accounts_list.each do |account|
        if account["accountNo"].blank?
          actype_hash[account["card"]["cardNumber"]] = account["accountType"]
        else
          actype_hash[account["accountNo"]] = account["accountType"]
        end
      end
    end
    return actype_hash
  end

  def self.get_investment_suggestions(phone_no,amount,tenure)
    balances = AnalyzeAccount.get_account_balances(phone_no)
    matching_tenure_investments = {}
    diff_bal_hash = {}
    balances.each do |ac,bal|
      diff_bal_hash[ac] = [bal,amount-bal]
    end
    final_amounts = {}
    investment_options = AnalyzeAccount::INVESTMENT_OPTIONS
    investment_options.each do |k,i_data|
      if i_data["min_tenure_months"].to_i <= tenure
        matching_tenure_investments[k] = i_data
      end
    end
    diff_bal_hash.each do |ac,vals|
      final_amounts[ac] = {}
      matching_tenure_investments.each do |k,v|
        to_earn = 0.0
        to_invest = 0.0
        to_earn = vals[1]
        to_invest = (to_earn*100)/(100+v["rate"].to_f)
        final_amounts[ac][k] = [v["min_tenure_months"],v["rate"],to_invest]
      end
    end
  end
  
end


