module Cinema
  class Parser

    TMDB_KEY = "6e73fb47bbd523d5291b70dd329bb05a"

    attr_reader :movies_info, :data

    def initialize(moviecollection)
      @moviecollection = moviecollection
      @movies_info = get_movies_info(@moviecollection)
      Tmdb::Api.key(TMDB_KEY)
      @data = get_data
      @template = template
    end

    def get_movies_info(moviecollection)
      moviecollection.map do |movie|
        movie.to_h
      end
    end

    def get_data
      # Returns hash with all movies info including budget, poster
      # and alternative titles.
      progressbar = ProgressBar.create(total: movies_info.length)
      movies_info.map do |movie_hash|
        progressbar.increment
        parse_data(movie_hash)
      end
    end

    def parse_data(movie_hash)
      tmdb_movie_id = get_tmdb_movie_id(movie_hash[:imdb_id])
      imdb_page = page(movie_hash[:link])
      title = movie_hash[:title]
      {title => {
        budget: parse_budget(imdb_page),
        poster_url: get_poster_url(width: 185, id: tmdb_movie_id),
        alternative_titles: get_alternative_titles(tmdb_movie_id)
        }.merge(movie_hash)
      }
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
      budget = page.at('h4:contains("Budget:")').parent.text.gsub(/\D/, '')
    end

    def page(link)
      Nokogiri::HTML(open(link))
    end

    def save_to_html
      # Gets main page tempale (body.html) and adds to it
      # movie cards after <h1> tag.
      # Result will be saved to 'movies.html'.
      file = File.open('example/body.html') { |f| Nokogiri::HTML(f) }
      file.at_css('h1').add_next_sibling(render)
      File.open('example/movies.html', 'w') { |f| f.write(file) }
    end

    def save_to_yml
      yml_structure = data.to_yaml
      File.open("example/data.yml", "w") do |file|
        file.puts yml_structure
      end
    end

    def render
      ERB.new(@template).result(binding)
    end

    def template
      %{
        <div class="row" style="margin-bottom: 20px">
        <% cards_count = 0 %>
        <% @data.each_with_index do |movie_hash, index| %>
          <% cards_count += 1 %>
          <% movie_data = movie_hash.values.first %>
              <div class="col-3">
                <div class="card">
                  <img class="card-img-top" src="<%= movie_data[:poster_url] %>" alt="<%= movie_hash[:title] %>">
                  <div class="card-block">
                    <h4 class="card-title"><%= movie_hash[:title] %></h4>
                    <p class="card-text">
                      <b>Director:</b> <%= movie_data[:director] %> <br />
                      <b>Budget:</b> <%= movie_data[:budget] %>$ <br />
                      <b>Year:</b> <%= movie_data[:year] %> <br />
                    </p>
                  </div>
                </div>
              </div>
              <% if cards_count%4 == 0 %>
                </div>
                <div class="row">
              <% end %>
        <% end %>
      }
    end
  end
end