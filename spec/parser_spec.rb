require 'cinema'

describe Cinema::Parser, :vcr do
  let(:single_movie_data) { { link: 'http://imdb.com/title/tt0036775/?ref_=chttp_tt_81', title: 'Double Indemnity', year: 1944, country: 'USA', date: '1944-04-24', genre: 'Crime,Drama,Film-Noir', length: '107 min', rating: '8.4', director: 'Billy Wilder', actors: 'Fred MacMurray,Barbara Stanwyck,Edward G. Robinson' } }
  let(:movie) { Cinema::Movie.create(single_movie_data) }
  let(:single_movie_collection) { [movie] }
  let(:single_movie_parser) {described_class.new(single_movie_collection)}

  before {
    single_movie_parser.save_to_yml
    single_movie_parser.save_to_html
  }

  after(:all) {
    File.delete('example/data.yml')
    File.delete('example/movies.html')
  }

  describe '#save_to_yml' do

    let(:yml_path) { Pathname.new('example/data.yml') }
    let(:yml) { YAML.load(yml_path.read) }

    it { expect(yml_path).to exist }
    it 'contains one movie get_data'  do
      expect(yml).to have_attributes(count: 1)
    end
  end

  describe '#save_to_html' do

    let(:html_path) { Pathname.new('example/movies.html') }
    let(:html) { Nokogiri::HTML(open(html_path)) }

    it { expect(html_path).to exist }
    it 'contains 5 children nodes' do
      expect(html.at_css('.container').children.length).to eq(5)
    end
  end

  describe '#parse_budget' do

    let(:imdb_page) { Nokogiri::HTML(open('spec/mocks/imdb_page.htm')) }

    subject { single_movie_parser }

    it 'returns budget if imdb page has one' do
      expect(subject.parse_budget(imdb_page)).to eq('25000000')
    end
  end

  describe '#get_alternative_titles' do

    let(:alternative_titles_response) {
    [{"iso_3166_1"=>"RU", "title"=>"Крёстный отец 1"}, {"iso_3166_1"=>"MX", "title"=>"El padrino"}, {"iso_3166_1"=>"RU", "title"=>"Крёстный отец"}, {"iso_3166_1"=>"US", "title"=>"The Godfather Part I"}, {"iso_3166_1"=>"ES", "title"=>"El Padrino I"}, {"iso_3166_1"=>"US", "title"=>"The Godfather Part 1"}, {"iso_3166_1"=>"US", "title"=>"Mario Puzo's The Godfather"}, {"iso_3166_1"=>"US", "title"=>"The Godfather: The Coppola Restoration"}, {"iso_3166_1"=>"PL", "title"=>"Ojciec Chrzestny"}, {"iso_3166_1"=>"TW", "title"=>"教父"}, {"iso_3166_1"=>"RU", "title"=>"Крестный отец 1"}, {"iso_3166_1"=>"US", "title"=>"The Godfather: Part I"}, {"iso_3166_1"=>"FR", "title"=>"Le Parrain 1"}, {"iso_3166_1"=>"BR", "title"=>"O Poderoso Chefão"}, {"iso_3166_1"=>"US", "title"=>"The Godfather 1"}, {"iso_3166_1"=>"IT", "title"=>"Il Padrino (1972)"}, {"iso_3166_1"=>"KR", "title"=>"대부"}, {"iso_3166_1"=>"US", "title"=>"Godfather, The"}, {"iso_3166_1"=>"GR", "title"=>"Ο Νονός"}, {"iso_3166_1"=>"DE", "title"=>"Der Pate - Teil 1"}, {"iso_3166_1"=>"PT", "title"=>"O Poderoso Chefão"}, {"iso_3166_1"=>"DE", "title"=>"Der Pate - Teil I - The Godfather"}]
  }

    subject { single_movie_parser.get_alternative_titles(238) }

    it 'retrieves alternative titles for the movie' do
        expect(subject['titles']).to eq(alternative_titles_response)
    end
  end

  describe '#get_poster_url' do

    subject { single_movie_parser }

    context 'poster custom width' do
      it 'retrieves tmdb movie poster url with custom width' do
          expect(subject.get_poster_url(width: 250, id: 238)).to eq('http://image.tmdb.org/t/p/w250//rPdtLWNsZmAtoZl9PK7S2wE3qiS.jpg')
      end
    end

    context 'poster default width' do
      it 'retrieves tmdb movie poster url with default width (185px)' do
          expect(subject.get_poster_url(id: 238)).to eq('http://image.tmdb.org/t/p/w185//rPdtLWNsZmAtoZl9PK7S2wE3qiS.jpg')
      end
    end
  end

  describe '#get_tmdb_movie_id' do

    subject { single_movie_parser.get_tmdb_movie_id('tt0068646') }

    it 'retrieves tmdb movie id by imdb movie id' do
        expect(subject).to eq(238)
    end
  end
end