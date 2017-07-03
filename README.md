# Cinema: Movies Management and Cataloging

## Description

With Cinema gem you can:
 * Manage movie theatre repertoire and periods.
 * Import movies from CSV.
 * Export collection to YAML or HTML.

### Create your own movie collection

Assume we have small 'movie.csv' file:

```text
http://imdb.com/title/tt0111161/?ref_=chttp_tt_1|The Shawshank Redemption|1994|USA|1994-10-14|Crime,Drama|142 min|9.3|Frank Darabont|Tim Robbins,Morgan Freeman,Bob Gunton
```

Create a movie collection from this file:

```ruby
collection = Cinema::MovieCollection.new('movie.csv')

collection.inspect
'=> <Cinema::MovieCollection:0x007fc65e01d548 @movies=[#<Cinema::ModernMovie:0x007fc65d15e4a8 @link="http://imdb.com/title/tt0111161/?ref_=chttp_tt_1", @title="The Shawshank Redemption", @year=1994, @country="USA", @date=#<Date: 1994-10-14 ((2449640j,0s,0n),+0s,2299161j)>, @genre=["Crime", "Drama"], @length="142 min", @rating=9.3, @director="Frank Darabont", @actors=["Tim Robbins", "Morgan Freeman", "Bob Gunton"], @collection=#<Cinema::MovieCollection:0x007fc65e01d548 ...>, @price=#<Money fractional:300 currency:USD>>]>'
```

Depending on movie year, movie class inside collection will be:

``` ruby
1900..1944 => AncienMovie
1945..1967 => ClassicMovie
1968..1999 => ModernMovie
2000..Date.today.cwyear => NewMovie
```

## Examples

Cinema gem provides both online and offline movie theatre management models.

### Movie collection for online theatres

Create new Netflix collection:

```ruby
netflix = Cinema::Examples::Netflix.new('movies.csv')
```

Netflix collection has built-in user balance:
```ruby
netflix.user_balance
=> #<Money fractional:0 currency:USD>
```
Balance replenishment:
```ruby
netflix.pay 25
=> #<Money fractional:2500 currency:USD>
```

You can get movie price with 'how_much?' method:
```ruby
netflix.how_much?('The Kid')
=> #<Money fractional:100 currency:USD>
```

You can filter movies by genre or by country:

```ruby
netflix.by_genre.crime
netflix.by_country.usa
```

Lets pick random movie to show. Movies with higher rating has higher priority.
User balance will be decreased appropriately.
```ruby
netflix.user_balance
=> #<Money fractional:200 currency:USD>

netflix.show('The Kid')
=> "Now showing: The Terminator."

netflix.user_balance
=> #<Money fractional:100 currency:USD>
```

You can define custom filters:
```ruby
netflix.define_filter(:new_sci_fi) { |movie| !movie.title.include?('Terminator') && movie.genre.include?('Action') && movie.year > 2003 }
# Show results
netflix.show(new_sci_fi: true)

# Custom filter with argument.
netflix.define_filter(:new_action) { |movie, year| movie.year > year && movie.genre.include?('Action') }
# Show results
netflix.show(new_action: 2003)

# You can also define new filter by inheriting from an existing one.
netflix.define_filter(:newest_action, from: :new_action, arg: 2014)
```

### Movie theatre management
Cinema gem provides you a simple DSL for managing repertoire and periods.

```ruby

using MoneyHelper

theatre =
  Cinema::Examples::Theatre.new('movies_info.csv') do
    hall :red, title: 'Red', places: 100
    hall :blue, title: 'Blue', places: 50
    hall :green, title: 'Green (deluxe)', places: 12

    period '09:00'..'11:00' do
      description 'Comedy morning'
      filters genre: 'Comedy', year: 1900..1980
      price 10
      hall :red, :blue
    end

    period '11:00'..'16:00' do
      description 'Arnold lovers '
      title 'The Terminator'
      price 50
      hall :green
    end

    period '16:00'..'20:00' do
      description 'Modern action evening'
      filters genre: ['Action', 'Comedy'], year: 2007..Time.now.year
      price 20
      hall :red, :blue
    end
  end
```

To see movie showtimes call 'when?':
```ruby
theatre.when?('The Kid')
=> "The Kid показывают с 6:00 до 11:00"
```

Buy movie ticket:
```ruby
theatre.balance
=> #<Money fractional:000 currency:USD>

theatre.buy_ticket('The Kid')
=> "Вы купили билет на The Kid"

# Theatre balance will be replenished appropriately.
theatre.balance
=> #<Money fractional:300 currency:USD>
```

To reset theatre balance after encashment use 'take('Bank')':
```ruby
theatre.balance
=> #<Money fractional:300 currency:USD>

theatre.take('Bank')
=> Проведена инкассация.

theatre.balance
=> #<Money fractional:000 currency:USD>
```

## Build HTML page with collection data

Parser class makes requests to TMDB API to grab some data, so you need to set your TMDB API Key in 'config/keys.yml'.

Then create new parser instance:
```ruby
collection = Cinema::MovieCollection.new('./lib/movies.txt')
parser = Parser.new(collection)
```
Parser grabs movie poster, budget and alternative titles from tmdb and imdb.

Now you can save your data to html page:
```ruby
parser.save_to_html
```

 ![Alt text](https://image.prntscr.com/image/eF590cizQouMXjtQoOOvNQ.png)

## Build YAML file with collection data

Same as for HTML, set your TMDB API Key in 'config/keys.yml' first.

After creating new Parser instance:
```ruby
parser.save_to_yml
```