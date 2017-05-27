require 'money'
require 'cinema'
require 'cinema/money_helper'

describe Cinema::Examples::Theatre do
  using MoneyHelper

  let(:theatre) { described_class.new('lib/movies.txt') }

  let(:custom_theatre) {
    described_class.new('lib/movies.txt') do
      hall :red, title: 'Красный зал', places: 100
      hall :blue, title: 'Синий зал', places: 50
      hall :green, title: 'Зелёный зал (deluxe)', places: 12

      period '09:00'..'11:00' do
        description 'Утренний сеанс'
        filters genre: 'Comedy', year: 1900..1980
        price 10
        hall :red, :blue
      end

      period '11:00'..'16:00' do
        description 'Спецпоказ'
        title 'The Terminator'
        price 50
        hall :green
      end

      period '16:00'..'20:00' do
        description 'Вечерний сеанс'
        filters genre: ['Action', 'Drama'], year: 2007..Time.now.year
        price 20
        hall :red, :blue
      end

      period '19:00'..'22:00' do
        description 'Вечерний сеанс для киноманов'
        filters year: 1900..1945 # exclude_country: 'USA'
        price 30
        hall :green
      end
    end
  }

  let(:wrong_schedule_theatre) {
    described_class.new('lib/movies.txt') do
      hall :red, title: 'Красный зал', places: 100
      hall :blue, title: 'Синий зал', places: 50
      hall :green, title: 'Зелёный зал (deluxe)', places: 12

      period '09:00'..'11:00' do
        description 'Утренний сеанс'
        filters genre: 'Comedy', year: 1900..1980
        price 10
        hall :red, :blue
      end

      period '10:00'..'16:00' do
        description 'Спецпоказ'
        title 'The Terminator'
        price 50
        hall :green, :blue
      end

      period '16:00'..'20:00' do
        description 'Вечерний сеанс'
        filters genre: ['Action', 'Drama'], year: 2007..Time.now.year
        price 20
        hall :red, :blue
      end

      period '19:00'..'22:00' do
        description 'Вечерний сеанс для киноманов'
        filters year: 1900..1945 # exclude_country: 'USA'
        price 30
        hall :green, :red
      end
    end
  }

  let(:morning_movie) do
    Cinema::AncientMovie.new( { 'link' => 'http://imdb.com/title/tt0034583/?ref_=chttp_tt_32', 'title' => 'Casablanca',  'year' => '1942',  'country' => 'USA', 'date' => '1943-01-23', 'genre' => 'Drama,Romance,War',  'length' => '102 min',  'rating' => '8.6', 'director' => 'Michael Curtiz', 'actors' => 'Humphrey Bogart,Ingrid Bergman,Paul Henreid', 'collection' => collection } )
  end

  let(:afternoon_movie) do
    Cinema::ClassicMovie.new( { 'link' => 'http://imdb.com/title/tt0061722/?ref_=chttp_tt_248', 'title' => 'The Graduate', 'year' => '1967',  'country' => 'USA', 'date' => '1967-12-22', 'genre' => 'Comedy,Drama,Romance', 'length' => '106 min', 'rating' => '8.0', 'director' => 'Mike Nichols', 'actors' => 'Dustin Hoffman,Anne Bancroft,Katharine Ross', 'collection' => collection } )
  end

  let(:evening_movie) do
    Cinema::AncientMovie.new( { 'link' => 'http://imdb.com/title/tt0034583/?ref_=chttp_tt_32',  'title' => 'Casablanca',  'year' => '1942', 'country' => 'USA', 'date' => '1943-01-23', 'genre' => 'Drama,Romance,War', 'length' => '102 min',  'rating' => '8.6', 'director' => 'Michael Curtiz', 'actors' => 'Humphrey Bogart,Ingrid Bergman,Paul Henreid', 'collection' => collection } )
  end

  let(:collection) { Cinema::MovieCollection.new('lib/movies.txt') }

  context 'show' do
    it 'shows ancient movies on mornings' do
      allow(theatre).to receive(:fetch_movie).and_return(morning_movie)
      expect(theatre.show('10:20')).to eq('Casablanca - старый фильм 1942')
    end

    it 'shows comedy and adventure movies on afternoon' do
      allow(theatre).to receive(:fetch_movie).and_return(afternoon_movie)
      expect(theatre.show('12:20')).to eq('The Graduate - классический фильм Mike Nichols (ещё 1 его фильмов в списке)')
    end

    it 'shows drama and horror movies on evening' do
      allow(theatre).to receive(:fetch_movie).and_return(evening_movie)
      expect(theatre.show('18:20')).to eq('Casablanca - старый фильм 1942')
    end

    it 'raises an error if time is not presented in schedule' do
      expect { theatre.show('1:20') }.to raise_error.with_message('Наш кинотеатр работает с 6:00 до 23:00. Вы выбрали время 1:20.')
    end
  end

  context 'fetch_movie' do
    it 'fetches right movie for morning' do
      expect(theatre.send(:fetch_movie, :morning)).to be_a(Cinema::AncientMovie)
    end

    it 'fetches right movie for afternoon' do
      expect((theatre.send(:fetch_movie, :afternoon).genre && %w[Comedy Adventure]).empty?).to eq(false)
    end

    it 'fetches right movie for evening' do
      expect((theatre.send(:fetch_movie, :evening).genre && %w[Drama Horror]).empty?).to eq(false)
    end
  end

  context 'when?' do
    it 'shows when the selected movie is playing' do
      expect(theatre.when?('The Kid')).to eq('The Kid показывают с 6:00 до 11:00')
    end
  end

  context 'cash' do
    it 'returns balance in cashbox' do
      expect(theatre.cash).to eq(0.to_money)
    end

    it 'returns cashbox balance for every theatre instance' do
      theatre2 = described_class.new('lib/movies.txt')
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
      expect { theatre.buy_ticket('The Kid') }.to change { theatre.balance }.from(0.to_money).to(3.to_money)
    end
  end

  context 'opening_hours' do
    it 'sums all opening hours in array of time ranges' do
      expected_array = [
        Time.parse('6:00')..Time.parse('11:00'),
        Time.parse('12:00')..Time.parse('17:00'),
        Time.parse('18:00')..Time.parse('23:00')]
      expect(theatre.send(:opening_hours)).to match_array(expected_array)
    end
  end

  context 'create_schedule' do
    it 'creates default schedule hash if no custom period given' do
      default_schedule = {
        morning: {
          time: ('6:00'..'11:00'),
          filters: { period: :ancient },
          price: 3
        },
        afternoon: {
          time: ('12:00'..'17:00'),
          filters: { genre: %w[Comedy Adventure] },
          price: 5
        },
        evening: {
          time: ('18:00'..'23:00'),
          filters: { genre: %w[Drama Horror] },
          price: 10
        }
      }
      expect(theatre.instance_variable_get(:@schedule)).to eq(default_schedule)
    end

    it 'creates custom schedule for custom theatre' do
      custom_schedule = {
        :'09:00..11:00' => {
          time: ('09:00'..'11:00'),
          filters: {genre: 'Comedy', year: 1900..1980},
          price: 10,
          hall: [:red, :blue]
        },
        :'11:00..16:00' => {
          time: ('11:00'..'16:00'),
          filters: {title: 'The Terminator'},
          price: 50,
          hall: [:green]
        },
        :'16:00..20:00' => {
          time: ('16:00'..'20:00'),
          filters: {genre: ['Action', 'Drama'], year: 2007..Time.now.year},
          price: 20,
          hall: [:red, :blue]
        },
        :'19:00..22:00' => {
          time: ('19:00'..'22:00'),
          filters: {year: 1900..1945},
          price: 30,
          hall: [:green]
        }
      }
      expect(custom_theatre.instance_variable_get(:@schedule)).to eq(custom_schedule)
    end
  end

  context 'check_periods' do
    it 'returns error if one hall has different periods' do
      expect { wrong_schedule_theatre }.to raise_error.with_message('Пересечения периодов: c 10:00 по 11:00 в зале [:blue]; c 19:00 по 20:00 в зале [:red];')
    end
  end
end
