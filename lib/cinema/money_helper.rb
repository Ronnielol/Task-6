module MoneyHelper

	refine Numeric do
		def to_money
		 	Money.new(self*100, "USD")
		end
	end

end