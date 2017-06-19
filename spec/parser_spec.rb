require 'cinema'

describe Cinema::Parser, :vcr do
  let(:data) { { link: 'http://imdb.com/title/tt0036775/?ref_=chttp_tt_81', title: 'Double Indemnity', year: 1944, country: 'USA', date: '1944-04-24', genre: 'Crime,Drama,Film-Noir', length: '107 min', rating: '8.4', director: 'Billy Wilder', actors: 'Fred MacMurray,Barbara Stanwyck,Edward G. Robinson' } }
  let(:movie) { Cinema::Movie.create(data) }
  let(:single_movie_collection) { [movie] }
  let(:collection) { Cinema::MovieCollection.new('lib/movies.txt') }
  let(:tmdb_client) {Tmdb::Api.key("6e73fb47bbd523d5291b70dd329bb05a")}
  let(:single_movie_parser) {described_class.new(single_movie_collection)}
  let(:alternative_titles_response) {
    [{"iso_3166_1"=>"RU", "title"=>"Крёстный отец 1"}, {"iso_3166_1"=>"MX", "title"=>"El padrino"}, {"iso_3166_1"=>"RU", "title"=>"Крёстный отец"}, {"iso_3166_1"=>"US", "title"=>"The Godfather Part I"}, {"iso_3166_1"=>"ES", "title"=>"El Padrino I"}, {"iso_3166_1"=>"US", "title"=>"The Godfather Part 1"}, {"iso_3166_1"=>"US", "title"=>"Mario Puzo's The Godfather"}, {"iso_3166_1"=>"US", "title"=>"The Godfather: The Coppola Restoration"}, {"iso_3166_1"=>"PL", "title"=>"Ojciec Chrzestny"}, {"iso_3166_1"=>"TW", "title"=>"教父"}, {"iso_3166_1"=>"RU", "title"=>"Крестный отец 1"}, {"iso_3166_1"=>"US", "title"=>"The Godfather: Part I"}, {"iso_3166_1"=>"FR", "title"=>"Le Parrain 1"}, {"iso_3166_1"=>"BR", "title"=>"O Poderoso Chefão"}, {"iso_3166_1"=>"US", "title"=>"The Godfather 1"}, {"iso_3166_1"=>"IT", "title"=>"Il Padrino (1972)"}, {"iso_3166_1"=>"KR", "title"=>"대부"}, {"iso_3166_1"=>"US", "title"=>"Godfather, The"}, {"iso_3166_1"=>"GR", "title"=>"Ο Νονός"}, {"iso_3166_1"=>"DE", "title"=>"Der Pate - Teil 1"}, {"iso_3166_1"=>"PT", "title"=>"O Poderoso Chefão"}, {"iso_3166_1"=>"DE", "title"=>"Der Pate - Teil I - The Godfather"}]
  }
  let(:yml_path) { Pathname.new('example/data.yml') }
  let(:html_path) { Pathname.new('example/movies.html') }
  let(:yml) { YAML.load(yml_path.read) }
  let(:html) { Nokogiri::HTML(open(html_path)) }
  let(:imdb_page) { Nokogiri::HTML(open('spec/mocks/imdb_page.htm')) }

  before { single_movie_parser.save_to_yml }
  before { single_movie_parser.save_to_html }

  context 'save_to_yml' do
    it { expect(yml_path).to exist }
    it 'contains one movie data'  do
      expect(yml).to have_attributes(count: 1)
      File.delete(yml_path)
    end
  end

  context 'save_to_html' do
    it { expect(html_path).to exist }
    it 'contains 5 children nodes' do
      expect(html.at_css('.container').children.length).to eq(5)
      File.delete(html_path)
    end
  end

  context 'parse_budget' do
    it 'returns budget if imdb page has one' do
      allow(single_movie_parser).to receive(:get_data).and_return('data')
      expect(single_movie_parser.parse_budget(imdb_page)).to eq('25000000')
    end
  end

  context 'get_alternative_titles' do
    it 'retrieves alternative titles for the movie' do
        tmdb_client
        response = single_movie_parser.get_alternative_titles(238)
        expect(response['titles']).to eq(alternative_titles_response)
    end
  end

  context 'get_poster_url' do
    it 'retrieves tmdb movie poster url with custom width' do
        response = single_movie_parser.get_poster_url(width: 250, id: 238)
        expect(response).to eq('http://image.tmdb.org/t/p/w250//rPdtLWNsZmAtoZl9PK7S2wE3qiS.jpg')
    end

    it 'retrieves tmdb movie poster url with default width (185px)' do
        response = single_movie_parser.get_poster_url(id: 238)
        expect(response).to eq('http://image.tmdb.org/t/p/w185//rPdtLWNsZmAtoZl9PK7S2wE3qiS.jpg')
    end
  end

  context 'get_tmdb_movie_id' do
    it 'retrieves tmdb movie id by imdb movie id' do
        response = single_movie_parser.get_tmdb_movie_id('tt0068646')
        expect(response).to eq(238)
    end
  end
end