require 'money'
require 'cinema'
require 'cinema/money_helper'

describe Cinema::Movie do
  describe 'create' do
    let(:base_data) { { 'link' => 'http://imdb.com/title/tt0036775/?ref_=chttp_tt_81', 'title' => 'Double Indemnity', 'year' => '', 'country' => 'USA', 'date' => '1944-04-24', 'genre' => 'Crime,Drama,Film-Noir', 'length' => '107 min', 'rating' => '8.4', 'director' => 'Billy Wilder', 'actors' => 'Fred MacMurray,Barbara Stanwyck,Edward G. Robinson' } }

    let(:wrong_data) { base_data.merge('year' => 2019) }

    subject { Cinema::Movie.create(data) }

    context 'ancient movie' do
      let(:data) { base_data.merge('year' => 1940) }
      it { is_expected.to be_a Cinema::AncientMovie }
    end

    context 'classic movie' do
      let(:data) { base_data.merge('year' => 1950) }
      it { is_expected.to be_a Cinema::ClassicMovie }
    end

    context 'modern movie' do
      let(:data) { base_data.merge('year' => 1990) }
      it { is_expected.to be_a Cinema::ModernMovie }
    end

    context 'new movie' do
      let(:data) { base_data.merge('year' => 2017) }
      it { is_expected.to be_a Cinema::NewMovie }
    end

    it 'throws an error when movie year is not in appropriate diapason' do
      expect { Cinema::Movie.create(wrong_data) }.to raise_error.with_message('У фильма неподходящий год. В базе могут быть только фильмы, снятые с 1900 года по настоящий.')
    end
  end

  describe Cinema::AncientMovie do
    using MoneyHelper

    let(:nf) { Cinema::Examples::Netflix.new('lib/movies.txt') }

    let(:collection) { Cinema::MovieCollection.new('lib/movies.txt') }

    subject do
      Cinema::AncientMovie.new({ 'link' => 'http://imdb.com/title/tt0036775/?ref_=chttp_tt_81', 'title' => 'Double Indemnity', 'year' => '1944', 'country' => 'USA', 'date' => '1944-04-24', 'genre' => 'Crime,Drama,Film-Noir', 'length' => '107 min', 'rating' => '8.4', 'director' => 'Billy Wilder', 'actors' => 'Fred MacMurray,Barbara Stanwyck,Edward G. Robinson' })
    end

    context 'description' do
      its(:description) { is_expected.to eq('Double Indemnity - старый фильм 1944') }
    end

    context 'initialize' do
      it 'creates object with class AncientMovie if movie year < 1945' do
        expect(nf.filter(title: 'Laura')[0]).to be_a(Cinema::AncientMovie)
      end
    end
  end

  describe Cinema::ClassicMovie do
    let(:nf) { Cinema::Examples::Netflix.new('lib/movies.txt') }

    let(:collection) { Cinema::MovieCollection.new('lib/movies.txt') }

    subject do
      Cinema::ClassicMovie.new({ 'link' => 'http://imdb.com/title/tt0036775/?ref_=chttp_tt_81', 'title' => 'Double Indemnity', 'year' => '', 'country' => 'USA', 'date' => '1944-04-24', 'genre' => 'Crime,Drama,Film-Noir', 'length' => '107 min', 'rating' => '8.4', 'director' => 'Billy Wilder', 'actors' => 'Fred MacMurray,Barbara Stanwyck,Edward G. Robinson', 'collection' => collection })
    end

    context 'description' do
      its(:description) { is_expected.to eq('Double Indemnity - классический фильм Billy Wilder (ещё 4 его фильмов в списке)') }
    end

    context 'initialize' do
      it 'creates object with class ClassicMovie if movie year >= 1945 and < 1968' do
        expect(nf.filter(title: 'The Graduate')[0]).to be_a(Cinema::ClassicMovie)
      end
    end
  end

  describe Cinema::ModernMovie do
    let(:nf) { Cinema::Examples::Netflix.new('lib/movies.txt') }

    let(:collection) { Cinema::MovieCollection.new('lib/movies.txt') }

    subject do
      Cinema::ModernMovie.new( { 'link' => 'http://imdb.com/title/tt0111161/?ref_=chttp_tt_1', 'title' => 'The Shawshank Redemption', 'year' =>'1994', 'country' => 'USA', 'date' => '1994-10-14',
                              'genre' => 'Crime,Drama', 'length' => '142 min', 'rating' => '9.3', 'actors' => 'Tim Robbins, Morgan Freeman, Bob Gunton', 'collection' => collection } )
    end

    context 'description' do
      its(:description) { is_expected.to eq('The Shawshank Redemption - современное кино: играют Tim Robbins, Morgan Freeman, Bob Gunton') }
    end

    context 'initialize' do
      it 'creates object with class ModernMovie if movie year >= 1968 and < 2000' do
        expect(nf.filter(title: 'Fight Club')[0]).to be_a(Cinema::ModernMovie)
      end
    end
  end

  describe Cinema::NewMovie do
    let(:nf) { Cinema::Examples::Netflix.new('lib/movies.txt') }

    let(:collection) { Cinema::MovieCollection.new('lib/movies.txt') }

    subject { Cinema::NewMovie.new( { 'link' => 'http://imdb.com/title/tt0209144/?ref_=chttp_tt_44', 'title' => 'Memento', 'year' => 2000, 'country' => 'USA','date' => '2001-05-25', 'genre' => 'Mystery,Thriller', 'length' => '113 min', 'rating' => '8.5', 'director' => 'Christopher Nolan',  'actors' => 'Guy Pearce,Carrie-Anne Moss,Joe Pantoliano', 'collection' => collection } ) }

    context 'description' do
      its(:description) { is_expected.to eq("Memento - новинка, вышло #{Date.today.cwyear - subject.year} лет назад") }
    end

    context 'initialize' do
      it 'creates object with class NewMovie if movie year >= 2000 til today' do
        expect(nf.filter(title: 'Memento')[0]).to be_a(Cinema::NewMovie)
      end
    end
  end
end
