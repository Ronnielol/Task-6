require 'money'
require 'modules/cashbox_implementation'

describe CashboxImplementation::Cashbox do

	class EDummyClass
	end

	class IDummyClass
	end

	before(:each) do
		@extended_dummy_class = EDummyClass.extend(CashboxImplementation::Cashbox)
		@including_dummy_class = IDummyClass.include(CashboxImplementation::Cashbox).new
	end

	context 'replenish balance' do 
		it 'adds money to cashbox' do
			expect{@extended_dummy_class.replenish_balance(25)}.to change{@extended_dummy_class.balance}.from(0.to_money).to(25.to_money)
			expect{@including_dummy_class.replenish_balance(25)}.to change{@including_dummy_class.balance}.from(0.to_money).to(25.to_money)
		end
	end

	context 'balance' do
		it 'returns current cashbox balance' do
			expect(@extended_dummy_class.balance).to eq(25.to_money)
		end
	end

	context 'take' do
		it 'set cashbox balance to zero' do
			expect{@extended_dummy_class.take('Bank')}.to change{@extended_dummy_class.balance}.from(25.to_money).to(0.to_money)
		end
		it 'raises error if argument is not Bank' do
			expect{@extended_dummy_class.take('robber')}.to raise_error.with_message("Вы не банк! Вызываем полицию!")
		end
	end
end