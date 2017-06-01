require 'money'
require 'cinema'
require 'cinema/money_helper'

describe Cinema::Examples::BlankFilter do
  let(:collection) { Cinema::MovieCollection.new('lib/movies.txt') }
  let(:filter_genre) { described_class.new(collection, 'genre')  }
  let(:filter_country) { described_class.new(collection, 'country') }
  let(:genres) { described_class.const_get('genres'.upcase)}

  context 'define_genres' do
    it 'defines filter method for every genre in GENRES' do
      genres.each do |genre|
        expect(filter_genre).to respond_to(genre.tr('-', '_').downcase.to_sym)
      end
    end

    it 'returns right movies depending on genre filter' do
      expect(filter_genre.action.map {|movie| movie.genre}).to all(include('Action'))
    end

    it 'raises nomethod error if filter is unknown' do
      expect{filter_genre.kek}.to raise_error(NoMethodError)
    end
  end

  context 'method_missing' do
    it 'defines filter method for a country if given header == country' do
      expect(filter_country).to respond_to('usa'.to_sym)
    end

    it 'returns right movies depending on country filter' do
      expect(filter_country.germany.map {|movie| movie.country}).to all(include('Germany'))
    end

    it 'raises error if country is unknown' do
      expect{filter_country.narnia}.to raise_error(RuntimeError, "Фильмы из страны Narnia не найдены. Проверьте правильность ввода.")
    end
  end

  context 'filter' do
    it 'returns filter proc' do
      expect(filter_genre.filter).to be_a(Proc)
    end
  end
end
