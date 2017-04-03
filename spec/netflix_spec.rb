require 'money'
require 'modules/moneyhelper'
require 'modules/task7'
require 'moviecollection'
require 'movie'
require 'netflix'

describe Netflix do

	let(:netflix) {Netflix.new('lib/movies.txt')}

	before(:each) do 
		netflix.pay(25)
	end

	context 'show' do
		it 'changes balance with movie price' do
			expect{netflix.show(title: 'The Kid')}.to change {netflix.user_balance}.from(25.to_money).to(24.to_money)
		end

		it 'shows title and description of the movie' do 
			expect{netflix.show(title: 'The Kid')}.to output("Now showing The Kid\n").to_stdout
		end

		it 'raises error when balance is too low to show movie ' do
			netflix.user_balance = 1.to_money
			expect{netflix.show(title: 'Inception')}.to raise_error.with_message("Не хватает средств. Сейчас на балансе 1.00, а данный фильм стоит 5.00.")
		end
	end

	context 'pay' do
		it 'allows to refill balance' do
			expect{netflix.pay(25)}.to change{netflix.user_balance}.from(25.to_money).to(50.to_money)
		end

		it 'cant accept payments =< 0$' do
			expect{netflix.pay(-1)}.to raise_error.with_message("Нельзя пополнить счет на 0 или отрициательное значение.")
		end
	end

	context 'how_much?' do
		it 'shows movie price' do
			netflix = Netflix.new('lib/movies.txt')	
			expect(netflix.how_much?('The Kid')).to eq(1.to_money)
		end
	end
end
