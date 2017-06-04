require 'cinema'

describe Cinema::Examples::ByGenre do
  let(:collection) { Cinema::MovieCollection.new('lib/movies.txt') }
  let(:genres_underline) { ["Crime", "Drama", "Action", "Biography", "History", "Western", "Adventure", "Fantasy", "Romance", "Mystery", "Sci_Fi", "Thriller", "Family", "Comedy", "War", "Animation", "Horror", "Music", "Film_Noir", "Musical", "Sport"] }
  let(:genres_hyphen) { ["Crime", "Drama", "Action", "Biography", "History", "Western", "Adventure", "Fantasy", "Romance", "Mystery", "Sci-Fi", "Thriller", "Family", "Comedy", "War", "Animation", "Horror", "Music", "Film-Noir", "Musical", "Sport"] }
  let(:test_movie) { Cinema::Movie.create({ link: 'http://imdb.com/title/tt0036775/?ref_=chttp_tt_81', title: 'Double Indemnity', year: 1944, country: 'USA', date: '1944-04-24', genre: 'Crime,Drama,Film-Noir', length: '107 min', rating: '8.4', director: 'Billy Wilder', actors: 'Fred MacMurray,Barbara Stanwyck,Edward G. Robinson' }) }
  subject { described_class.new(collection) }

  context 'get_genres' do
    it 'grabs all genres in collection' do
      expect(subject.send(:get_genres, collection)).to eq(genres_underline)
    end
  end

  context 'hyphen_to_underline' do
    it 'changes all hyphens in array items to underlines' do
      expect(subject.send(:hyphen_to_underline, genres_hyphen)).to eq(genres_underline)
    end
  end

  context 'genre_match_regexp' do
    it 'checks if movie genre with underline suits regexp' do
      underline_genre = test_movie.genre.map{|genre| genre.tr('-','_')}
      allow(test_movie).to receive(:genre).and_return(underline_genre)
      expect(subject.send(:genre_match_regexp, test_movie, 'film_noir')).to eq('Film_Noir')
    end

    it 'checks if movie genre does not suit wrong regexp' do
      expect(subject.send(:genre_match_regexp, test_movie, 'wrong_genre')).to be_nil
    end
  end

  context 'define_genre_methods' do
    it 'lets to filter movies with genre methods' do
      genres_underline.each do |genre|
        expect { subject.to all have_attributes(genre: array_including(genres_underline)) }
      end
    end
  end
end
