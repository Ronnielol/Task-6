module Cashbox

	def initialize_balance
		@cashbox_balance ||= 0.to_money
	end

	def replenish_balance(amount)
		@cashbox_balance += amount.to_money
	end

	def balance
		@cashbox_balance
	end

	def self.extended(base)
		base.initialize_balance
	end

	def take(who)
		if who != 'Bank'
			raise RuntimeError, 'Вы не банк! Вызываем полицию!' 
		end
		@cashbox_balance = 0.to_money
		puts "Проведена инкассация."
	end

end