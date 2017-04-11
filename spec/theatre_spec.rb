require 'money'
require 'cinema'

describe Cinema::Examples::Theatre do

	using Cinema::CashboxImplementation::MoneyHelper

	let(:theatre) {Cinema::Examples::Theatre.new('lib/movies.txt')}

	let(:morning_movie) {Cinema::Movies::AncientMovie.new('http://imdb.com/title/tt0034583/?ref_=chttp_tt_32', 'Casablanca', '1942', 'USA', '1943-01-23', 
			 	   'Drama,Romance,War', '102 min', '8.6', 'Michael Curtiz', 'Humphrey Bogart,Ingrid Bergman,Paul Henreid', collection)}

	let(:afternoon_movie) {Cinema::Movies::ClassicMovie.new('http://imdb.com/title/tt0061722/?ref_=chttp_tt_248', 'The Graduate', '1967', 'USA', '1967-12-22', 
			 	   'Comedy,Drama,Romance', '106 min', '8.0', 'Mike Nichols', 'Dustin Hoffman,Anne Bancroft,Katharine Ross', collection)}

	let(:evening_movie) {Cinema::Movies::AncientMovie.new('http://imdb.com/title/tt0034583/?ref_=chttp_tt_32', 'Casablanca', '1942', 'USA', '1943-01-23', 
			 	   'Drama,Romance,War', '102 min', '8.6', 'Michael Curtiz', 'Humphrey Bogart,Ingrid Bergman,Paul Henreid', collection)}

	let(:collection) {Cinema::Collections::MovieCollection.new('lib/movies.txt')}

	context 'show' do
		it 'shows ancient movies on mornings' do
			allow(theatre).to receive(:fetch_movie).and_return(morning_movie)
			expect(theatre.show('11.20')).to eq('Casablanca - старый фильм 1942')
		end

		it 'shows comedy and adventure movies on afternoon' do
			allow(theatre).to receive(:fetch_movie).and_return(afternoon_movie)
			expect(theatre.show('12.20')).to eq('The Graduate - классический фильм Mike Nichols (ещё 1 его фильмов в списке)')
		end

		it 'shows drama and horror movies on evening' do
			allow(theatre).to receive(:fetch_movie).and_return(evening_movie)
			expect(theatre.show('18.20')).to eq('Casablanca - старый фильм 1942')
		end

		it 'raises an error if time is not presented in schedule' do
			expect{theatre.show('1.20')}.to raise_error.with_message("Наш кинотеатр работает с 6 до 23. Вы выбрали время 1.20.")
		end
	end

	context 'fetch_movie' do
		it 'fetches right movie for morning' do
			expect(theatre.send(:fetch_movie, :morning)).to be_a(Cinema::Movies::AncientMovie)
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
			expect(theatre.when?('The Shawshank Redemption')).to eq("The Shawshank Redemption показывают с 18 до 23")
		end
	end

	context 'cash' do 
		it 'returns balance in cashbox' do
			expect(theatre.cash).to eq(0.to_money)
		end

		it 'returns cashbox balance for every theatre instance' do
			theatre2 = Cinema::Examples::Theatre.new('lib/movies.txt')
			theatre2.buy_ticket('The Kid')
			expect(theatre.cash).to eq(0.to_money)
			expect(theatre2.cash).to eq(3.to_money)
		end
	end

	context 'buy_ticket' do
		it 'returns message with bought movie information' do 
			expect(theatre.buy_ticket('The Kid')).to eq('Вы купили билет на The Kid')
		end

		it 'sends money for ticket to cashbox' do
			expect{theatre.buy_ticket('The Kid')}.to change{theatre.balance}.from(0.to_money).to(3.to_money) 
		end
	end
end