require 'moviecollection'
require 'movie'
require 'csv'

describe Movie do

	context 'create' do
		it 'creates movie with class depending on year' do
			row = CSV.foreach('lib/movies.txt', col_sep: '|', headers: %w{link title year country date 
			 genre length rating director actors}, force_quotes: 'false', converters: [:numeric]).map{|row| row}[0]
			movie = Movie.create(row, 'collection')
			expect(movie.class).to eq(ModernMovie)
		end
	end

end

describe AncientMovie do

	let(:nf) {Netflix.new('lib/movies.txt')}

	context 'description' do
		it 'returns right description for ancient movie' do
			movie = AncientMovie.new('link', 'title', '1943', 'country', 'date', 
			 	   'genre', 'length', 'rating', 'director', 'actors', 'collection')
			expect(movie.description).to eq('старый фильм 1943')
		end
	end

	context 'initialize' do 
		it 'creates object with class AncientMovie if movie year < 1945' do 
			expect(nf.filter(title: 'Laura')[0].class).to eq(AncientMovie)
		end
	end
end

describe ClassicMovie do

	let(:nf) {Netflix.new('lib/movies.txt')}

	context 'description' do
		it 'returns right description for classic movie' do
			collection = MovieCollection.new('lib/movies.txt')
			movie = ClassicMovie.new('link', 'title', '1946', 'country', 'date', 
			 	   'genre', 'length', 'rating', 'director', 'actors', collection)
			expect(movie.description).to include('классический фильм')
		end
	end

	context 'initialize' do 
		it 'creates object with class ClassicMovie if movie year >= 1945 and < 1968' do 
			expect(nf.filter(title: 'The Graduate')[0].class).to eq(ClassicMovie)
		end
	end
end

describe ModernMovie do

	let(:nf) {Netflix.new('lib/movies.txt')}

	context 'description' do
		it 'returns right description for modern movie' do
			movie = ModernMovie.new('link', 'title', '1994', 'country', 'date', 
			 	   'genre', 'length', 'rating', 'director', 'actors', 'collection')
			expect(movie.description).to eq('современное кино: играют actors')
		end
	end

	context 'initialize' do 
		it 'creates object with class ModernMovie if movie year >= 1968 and < 2000' do 
			expect(nf.filter(title: 'Fight Club')[0].class).to eq(ModernMovie)
		end
	end
end

describe NewMovie do

	let(:nf) {Netflix.new('lib/movies.txt')}

	context 'description' do
		it 'returns right description for new movie' do
			movie = NewMovie.new('link', 'title', '2001', 'country', 'date', 
			 	   'genre', 'length', 'rating', 'director', 'actors', 'collection')
			expect(movie.description).to include('новинка')
		end
	end

	context 'initialize' do 
		it 'creates object with class NewMovie if movie year >= 2000 til today' do 
			expect(nf.filter(title: 'Memento')[0].class).to eq(NewMovie)
		end
	end
end