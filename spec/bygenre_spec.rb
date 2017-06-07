require 'cinema'

describe Cinema::Examples::ByGenre do
  let(:collection) { Cinema::MovieCollection.new('lib/movies.txt') }
  let(:genres_underline) { ["Crime", "Drama", "Action", "Biography", "History", "Western", "Adventure", "Fantasy", "Romance", "Mystery", "Sci_Fi", "Thriller", "Family", "Comedy", "War", "Animation", "Horror", "Music", "Film_Noir", "Musical", "Sport"] }
  subject { described_class.new(collection) }

  context 'initialize' do
    it 'lets to filter movies with genre methods' do
      genres_underline.each do |genre|
        expect { subject.to all have_attributes(genre: array_including(genres_underline)) }
      end
    end
  end
end
