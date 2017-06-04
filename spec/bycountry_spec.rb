require 'cinema'

describe Cinema::Examples::ByCountry do
  let(:collection) { Cinema::MovieCollection.new('lib/movies.txt') }
  let(:test_movie) { Cinema::Movie.create({ link: 'http://imdb.com/title/tt0036775/?ref_=chttp_tt_81', title: 'Double Indemnity', year: 1944, country: 'USA', date: '1944-04-24', genre: 'Crime,Drama,Film-Noir', length: '107 min', rating: '8.4', director: 'Billy Wilder', actors: 'Fred MacMurray,Barbara Stanwyck,Edward G. Robinson' }) }
  subject { described_class.new(collection) }

  context 'country_match_regexp' do
    it 'checks if single-word country suits regexp' do
      expect(subject.send(:country_match_regexp, test_movie, 'usa')).to eq(0)
    end

    it 'checks if multiple-word country suits regexp' do
      allow(test_movie).to receive(:country).and_return('West Germany')
      expect(subject.send(:country_match_regexp, test_movie, 'germany')).to eq(5)
    end
  end

  context 'check_movies' do
    it 'raises error of movie array is empty' do
      movies = []
      expect { subject.send(:check_movies, movies, 'unknown_country') }.to raise_error('Фильмы из страны unknown_country не найдены. Проверьте правильность ввода.')
    end
  end

  context 'method_missing' do
    it 'filters movies by given country name' do
      expect { subject.germany.to all have_attributes(country: array_including('germany')) }
    end
  end
end
