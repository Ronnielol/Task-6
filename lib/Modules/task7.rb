require_relative 'moneyhelper'
require_relative 'cashbox'

module Task7

	module MoneyHelper

		def to_money
	  		Money.new(self*100, "USD")
		end

	end

	class Numeric

		include MoneyHelper

	end

	module Cashbox

		def initialize_balance
			@cashbox_balance ||= 0.to_money
		end

		def replenish_balance(amount)
			@cashbox_balance += amount.to_money
		end

		def reduce_balance(amount)
			@cashbox_balance -= amount.to_money
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

end

