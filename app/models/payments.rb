class Payments

  def self.get_payees(account_id)
    # cust_info = AnalyzeAccount::get_customer_info(phone_no)
    payees = Barclay::V1.payees(account_id) rescue []
    return payees
  end

  def self.transact(payee_id, amt)
    return {"id"=>"8573315966758950", "amount"=>{"moneyIn"=>"0.00", "moneyOut"=>"#{amt}"}, "accountBalanceAfterTransaction"=>{"position"=>"CR", "amount"=>"1500.00"}, "created"=>"06-09-2015 08:00:00 UTC", "description"=>"Texaco petrol station", "paymentDescriptor"=>{"id"=>"9701229312305196", "address"=>{"addressId"=>1, "number"=>"5", "buildingName"=>"Altrincham Retail Park", "street"=>"George Richards Way", "town"=>"Altrincham", "postalCode"=>"WA14 5GR", "country"=>"UK"}, "groupId"=>"4722", "logo"=>"", "name"=>"Texaco"}, "payee"=>nil, "pingIt"=>nil, "metadata"=>[{"key"=>nil, "value"=>nil}, {"key"=>"MERCHANT", "value"=>2731846737272357}], "notes"=>nil, "customerId"=>"8384692676375758", "paymentMethod"=>"CARD"}
  end
end
