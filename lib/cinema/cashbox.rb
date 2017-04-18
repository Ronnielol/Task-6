module Cinema

	module Cashbox

		using MoneyHelper

		def replenish_balance(amount)
			@cashbox_balance = balance + amount.to_money
		end

		def balance
			@cashbox_balance ||= 0.to_money
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
