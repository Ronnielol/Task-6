require 'money'
require 'modules/moneyhelper'
require 'modules/task7'
require 'moviecollection'
require 'movie'
require 'csv'

describe 'create' do

	let(:base_data) {{"link" => 'http://imdb.com/title/tt0036775/?ref_=chttp_tt_81', "title" => 'Double Indemnity', "year" => '', "country" => 'USA', "date" => '1944-04-24', "genre" => 'Crime,Drama,Film-Noir', "length" => '107 min', "rating" => '8.4', "director" => 'Billy Wilder', "actors" => 'Fred MacMurray,Barbara Stanwyck,Edward G. Robinson'}}

	let(:wrong_data){base_data.merge("year" => 2019)}

	subject{Movie.create(data, 'collection')}

	context 'ancient movie' do 
		let(:data){base_data.merge("year" => 1940)}
		it{is_expected.to be_a AncientMovie}
	end

	context 'classic movie' do 
		let(:data){base_data.merge("year" => 1950)}
		it{is_expected.to be_a ClassicMovie}
	end

	context 'modern movie' do 
		let(:data){base_data.merge("year" => 1990)}
		it{is_expected.to be_a ModernMovie}
	end

	context 'new movie' do 
		let(:data){base_data.merge("year" => 2017)}
		it{is_expected.to be_a NewMovie}
	end

	it 'throws an error when movie year is not in appropriate diapason' do
		expect{Movie.create(wrong_data, 'collection')}.to raise_error.with_message("У фильма неподходящий год. В базе могут быть только фильмы, снятые с 1900 года по настоящий.")
	end

end


describe AncientMovie do

	let(:nf) {Netflix.new('lib/movies.txt')}

	let(:collection) {MovieCollection.new('lib/movies.txt')}

	subject {AncientMovie.new('http://imdb.com/title/tt0034583/?ref_=chttp_tt_32', 'Casablanca', '1942', 'USA', '1943-01-23', 
			 	   'Drama,Romance,War', '102 min', '8.6', 'Michael Curtiz', 'Humphrey Bogart,Ingrid Bergman,Paul Henreid', collection)}

	context 'description' do
			its(:description) {is_expected.to eq('Casablanca - старый фильм 1942')}
	end

	context 'initialize' do 
		it 'creates object with class AncientMovie if movie year < 1945' do 
			expect(nf.filter(title: 'Laura')[0]).to be_a(AncientMovie)
		end
	end
end

describe ClassicMovie do

	let(:nf) {Netflix.new('lib/movies.txt')}

	let(:collection) {MovieCollection.new('lib/movies.txt')}

	subject {ClassicMovie.new('http://imdb.com/title/tt0036868/?ref_=chttp_tt_195', 'The Best Years of Our Lives', '1946', 'USA', '1947-06-17', 
			 	   'Drama,Romance,War', '172 min', '8.2', 'William Wyler', 'Fredric March,Dana Andrews,Myrna Loy', collection)}

	context 'description' do
		its(:description) {is_expected.to eq('The Best Years of Our Lives - классический фильм William Wyler (ещё 2 его фильмов в списке)')} 
	end

	context 'initialize' do 
		it 'creates object with class ClassicMovie if movie year >= 1945 and < 1968' do 
			expect(nf.filter(title: 'The Graduate')[0]).to be_a(ClassicMovie)
		end
	end
end

describe ModernMovie do

	let(:nf) {Netflix.new('lib/movies.txt')}

	let(:collection) {MovieCollection.new('lib/movies.txt')}

	subject {ModernMovie.new('http://imdb.com/title/tt0111161/?ref_=chttp_tt_1', 'The Shawshank Redemption', '1994', 'USA', '1994-10-14', 
			 	   'Crime,Drama', '142 min', '9.3', 'Frank Darabont', 'Tim Robbins,Morgan Freeman,Bob Gunton', collection)}

	context 'description' do
		its(:description) {is_expected.to eq('The Shawshank Redemption - современное кино: играют Tim Robbins, Morgan Freeman, Bob Gunton')}
	end

	context 'initialize' do 
		it 'creates object with class ModernMovie if movie year >= 1968 and < 2000' do 
			expect(nf.filter(title: 'Fight Club')[0]).to be_a(ModernMovie)
		end
	end
end

describe NewMovie do

	let(:nf) {Netflix.new('lib/movies.txt')}

	let(:collection) {MovieCollection.new('lib/movies.txt')}

	subject {NewMovie.new('http://imdb.com/title/tt0209144/?ref_=chttp_tt_44', 'Memento', 2000, 'USA', '2001-05-25', 'Mystery,Thriller', '113 min', '8.5', 'Christopher Nolan', 'Guy Pearce,Carrie-Anne Moss,Joe Pantoliano', collection)}

	context 'description' do
		its(:description) {is_expected.to eq("Memento - новинка, вышло #{Date.today.cwyear - subject.year} лет назад")}
	end

	context 'initialize' do 
		it 'creates object with class NewMovie if movie year >= 2000 til today' do 
			expect(nf.filter(title: 'Memento')[0]).to be_a(NewMovie)
		end
	end
end