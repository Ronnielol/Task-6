require 'moviecollection'
require 'movie'
require 'theatre'

describe 'Theatre' do

	context 'show' do
		it 'shows ancient movies on mornings' do
			theatre = Theatre.new('lib/movies.txt')
			expect{theatre.show('11.20')}.to output(/старый фильм/).to_stdout
		end
		xit 'shows comdies and adventure movies on afternoon' do
			theatre = Theatre.new('lib/movies.txt')
		end
	end

	context 'when?' do
		it 'shows when the selected movie is playing' do
			theatre = Theatre.new('lib/movies.txt')
			expect{theatre.when?('The Shawshank Redemption')}.to output("Фильм The Shawshank Redemption показывают вечером с 18 до 23\n").to_stdout
		end
	end
end