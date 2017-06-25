# frozen_string_literal: true

module Cinema
  # Uses info from imdb and tmdb for generating html file.
  class Parser
    TMDB_KEY = YAML.load_file('config/keys.sample.yml')['tmdb_key']

    attr_reader :movies_info, :data

    def initialize(moviecollection)
      @moviecollection = moviecollection
      @movies_info = get_movies_info(@moviecollection)
      Tmdb::Api.key(TMDB_KEY)
      @data = get_data
    end

    def get_movies_info(moviecollection)
      moviecollection.map(&:to_h)
    end

    def get_data
      # Returns hash with all movies info including budget, poster
      # and alternative titles.
      progressbar = ProgressBar.create(total: movies_info.length)
      movies_info.first(2).map do |movie_hash|
        progressbar.increment
        parse_data(movie_hash)
      end
    end

    def parse_data(movie_hash)
      tmdb_movie_id = get_tmdb_movie_id(movie_hash[:imdb_id])
      imdb_page = page(movie_hash[:link])
      title = movie_hash[:title]
      { title => {
        budget: parse_budget(imdb_page),
        poster_url: get_poster_url(width: 185, id: tmdb_movie_id),
        alternative_titles: get_alternative_titles(tmdb_movie_id)
      }.merge(movie_hash) }
    end

    def get_poster_url(width: 185, id: nil)
      path = Tmdb::Movie.detail(id)['poster_path']
      "http://image.tmdb.org/t/p/w#{width}/#{path}"
    end

    def get_alternative_titles(tmdb_id)
      Tmdb::Movie.alternative_titles(tmdb_id)
    end

    def get_tmdb_movie_id(imdb_id)
      Tmdb::Find.imdb_id(imdb_id)['movie_results'][0]['id']
    end

    def parse_budget(page)
      return if page.at('h4:contains("Budget:")').nil?
      page.at('h4:contains("Budget:")').parent.text.gsub(/\D/, '')
    end

    def page(link)
      Nokogiri::HTML(open(link))
    end

    def save_to_html
      body_file = File.read('example/body.html.erb')
      File.write('example/movies.html', render(body_file))
    end

    def save_to_yml
      File.write('example/data.yml', data.to_yaml)
    end

    def render(template)
      ERB.new(template).result(binding)
    end
  end
end
