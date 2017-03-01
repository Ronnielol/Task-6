require 'moviecollection'
require 'movie'
require 'netflix'

describe 'Netflix' do
	context 'show' do
		it 'changes balance with movie price' do
			netflix = Netflix.new('lib/movies.txt')
			netflix.pay(25)
			expect{netflix.show(title: 'The Kid')}.to change {netflix.balance}.from(25).to(24)
		end

		it 'shows title and description of the movie' do 
			netflix = Netflix.new('lib/movies.txt')
			netflix.pay(25)
			expect{netflix.show(title: 'The Kid')}.to output("Now showing The Kid\nОписание фильма:\nThe Kid - старый фильм 1921\n").to_stdout
		end

		it 'raises error when balance is too low to show movie ' do
			netflix = Netflix.new('lib/movies.txt')
			netflix.pay(3)
			expect{netflix.show(title: 'Inception')}.to raise_error.with_message("Не хватает денег")
		end
	end

	context 'pay' do
		it 'allows to pay for movie' do
			netflix = Netflix.new('lib/movies.txt')
			netflix.pay(25)
			expect(netflix.balance).to eq(25)
		end
	end

	context 'how_much?' do
		it 'shows movie price' do
			netflix = Netflix.new('lib/movies.txt')	
			expect{netflix.how_much?('The Kid')}.to output("1\n").to_stdout
		end
	end
end
