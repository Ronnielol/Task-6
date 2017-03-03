require 'moviecollection'
require 'movie'
require 'theatre'

describe Theatre do

	let (:theatre) { Theatre.new('lib/movies.txt')}

	context 'show' do
		it 'shows ancient movies on mornings' do
			expect{theatre.show('11.20')}.to output(/старый фильм/).to_stdout
		end
	end

	context 'when?' do
		it 'shows when the selected movie is playing' do
			expect{theatre.when?('The Shawshank Redemption')}.to output("Фильм The Shawshank Redemption показывают вечером с 18 до 23\n").to_stdout
		end
	end
end