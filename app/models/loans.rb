class Loans
  LENDERS = [
    {"institute_name"=>"CapitalOne", 'rate' => 18, 'tenure': 180},
    {"institute_name"=>"LendingKart", 'rate' => 12, 'tenure': 90},
    {"institute_name"=>"HDFC", 'rate' => 24, 'tenure': 180},
    {"institute_name"=>"Bajaj Finance", 'rate' => 19, 'tenure': 180},
    {"institute_name"=>"ICICI", 'rate' => 14, 'tenure': 90},
  ]

  def self.apply_loans(amount, account_info)
    offers = []
    LOANS::LENDERS.each do |lender|
      offer = lender
      offer['tenure'] = offer['tenure']/30
      offer['interest'] = (amount*(offer['tenure']/12)*offer['rate'])/100
      offer['repayment'] = offer['interest'] + amount
      offer['emi'] = offer['repayment']/offer['tenure']
    end
  end

  def self.submit_application
    return {'message' => 'We have submitted your application succesfully. The lender will get back to in next 24 hours.'}
  end
end
