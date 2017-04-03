require 'money'
require 'modules/task7'

describe Cashbox do

	let(:netflix) {Netflix.new('lib/movies.txt')}
	let(:theatre) {Theatre.new('lib/movies.txt')}

	context 'initialize_balance' do
		it 'initializes cashbox balance for Netflix' do
			expect(Netflix.balance).to eq(0.to_money)
		end

		it 'doesnt set balance to zero if it has already been initialized' do 
			nf1 = netflix
			nf1.pay(25)
			nf2 = netflix
			expect(Netflix.balance).to eq(25.to_money)
		end

		it 'initializes cashbox balance for Theatre' do
			expect(theatre.balance).to eq(0.to_money)
		end
	end	

	context 'replenish balance' do 
		it 'adds money to cashbox when module is extended' do
			expect{netflix.pay(25)}.to change{Netflix.balance}.from(25.to_money).to(50.to_money)
		end

		it 'adds money to cashbox when module is included' do
			expect{theatre.buy_ticket('The Kid')}.to change{theatre.balance}.from(0.to_money).to(3.to_money)
		end
	end

	context 'take' do 
		it 'set cashbox balance to zero' do
			expect{Netflix.take('Bank')}.to change{Netflix.balance}.from(50.to_money).to(0.to_money)
		end

		it 'prints incasation message' do
			expect{Netflix.take('Bank')}.to output("Проведена инкассация.\n").to_stdout
		end

		it 'raises error if incasator not a Bank' do
			expect{Netflix.take('Thief')}.to raise_error.with_message("Вы не банк! Вызываем полицию!")
		end
	end
end