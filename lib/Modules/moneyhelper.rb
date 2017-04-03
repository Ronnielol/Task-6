module MoneyHelper

	def to_money
  		Money.new(self*100, "USD")
	end

end

class Numeric

	include MoneyHelper

end
