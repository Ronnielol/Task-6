require 'cinema'

describe Cinema::Examples::ByCountry do
  let(:collection) { Cinema::MovieCollection.new('lib/movies.txt') }
  let(:test_movie) { Cinema::Movie.create({ link: 'http://imdb.com/title/tt0036775/?ref_=chttp_tt_81', title: 'Double Indemnity', year: 1944, country: 'USA', date: '1944-04-24', genre: 'Crime,Drama,Film-Noir', length: '107 min', rating: '8.4', director: 'Billy Wilder', actors: 'Fred MacMurray,Barbara Stanwyck,Edward G. Robinson' }) }
  subject { described_class.new(collection) }

  context 'method_missing' do
    it 'filters movies by given country name' do
      expect { subject.germany.to all have_attributes(country: array_including('germany')) }
    end

    it 'raises error if no movies found' do
      expect {subject.unknown_country}.to raise_error(NoMethodError)
    end
  end
end
