class Loans
  LENDERS = [
    {"institute_name"=>"CapitalOne", 'rate' => 18, 'tenure' => 180},
    {"institute_name"=>"LendingKart", 'rate' => 12, 'tenure'=> 90},
    {"institute_name"=>"HDFC", 'rate' => 24, 'tenure'=> 180},
    {"institute_name"=>"Bajaj Finance", 'rate' => 19, 'tenure'=> 180},
    {"institute_name"=>"ICICI", 'rate' => 14, 'tenure'=> 90},
  ]

  def self.apply_loans(index, amount)
    offers = []
    # LOANS::LENDERS.each do |lender|
      lender = Loans::LENDERS[index.to_i]
      offer = lender
      offer['tenure'] = offer['tenure'].to_s.to_f/30.0
      offer['interest'] = (amount*(offer['tenure']/12)*offer['rate'])/100
      offer['repayment'] = offer['interest'] + amount
      offer['emi'] = offer['repayment']/offer['tenure']
      offer['emi'] = offer['emi'].round(2)
      offer['tenure'] = offer['tenure'].to_i
    return offer
    # end
  end

  def self.submit_application
    return {'message' => 'We have submitted your application succesfully. The lender will get back to in next 24 hours.'}
  end
end
