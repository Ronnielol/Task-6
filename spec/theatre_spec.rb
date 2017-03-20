require 'moviecollection'
require 'movie'
require 'theatre'

describe Theatre do

	let(:theatre) { Theatre.new('lib/movies.txt')}

	let(:csv) {CSV.foreach('spec/spec_movies.txt', col_sep: '|', headers: %w{link title year country date 
			 genre length rating director actors}, force_quotes: 'false', converters: [:numeric]).map{|row| row}}

	let(:collection) {MovieCollection.new('lib/movies.txt')}

	let(:movie) {Movie.create(csv[1], collection)}

	context 'show' do
		it 'shows ancient movies on mornings' do
			expect(theatre.show('11.20')).to include('старый фильм')
		end

		it 'shows comedy and adventure movies on afternoon' do
			allow(theatre).to receive(:fetch_movie).and_return(movie)
			expect(theatre.show('12.20')).to eq('классический фильм Mike Nichols (ещё 1 его фильмов в списке)')
		end

		it 'shows drama and horror movies on evening' do
			allow(theatre).to receive(:fetch_movie).and_return(movie)
			expect(theatre.show('18.20')).to eq('классический фильм Mike Nichols (ещё 1 его фильмов в списке)')
		end

		it 'raises an error if time is not presented in schedule' do
			expect{theatre.show('1.20')}.to raise_error.with_message("Наш кинотеатр работает с 6 до 23. Вы выбрали время 1.20.")
		end
	end

	context 'fetch_movie' do
		it 'fetches right movie for morning' do
			expect(theatre.send(:fetch_movie, :morning)).to be_a(AncientMovie)
		end

		it 'fetches right movie for afternoon' do
			expect((theatre.send(:fetch_movie, :afternoon).genre & ['Comedy', 'Adventure']).empty?).to eq(false)
		end

		it 'fetches right movie for evening' do
			expect((theatre.send(:fetch_movie, :evening).genre & ['Drama', 'Horror']).empty?).to eq(false)
		end
	end

	context 'when?' do
		it 'shows when the selected movie is playing' do
			expect{theatre.when?('The Shawshank Redemption')}.to output("The Shawshank Redemption показывают с 18 до 23\n").to_stdout
		end
	end
end