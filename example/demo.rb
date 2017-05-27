require_relative '../lib/cinema'
require 'pry'

using MoneyHelper

theatre =
  Cinema::Examples::Theatre.new('lib/movies.txt') do
    hall :red, title: 'Красный зал', places: 100
    hall :blue, title: 'Синий зал', places: 50
    hall :green, title: 'Зелёный зал (deluxe)', places: 12

    period '09:00'..'11:00' do
      description 'Утренний сеанс'
      filters genre: 'Comedy', year: 1900..1980
      price 10
      hall :red
    end

    period '10:00'..'16:00' do
      description 'Спецпоказ'
      title 'The Terminator'
      price 50
      hall :green, :blue
    end

    period '16:00'..'20:00' do
      description 'Вечерний сеанс'
      filters genre: ['Action', 'Drama'], year: 2007..Time.now.year
      price 20
      hall :red, :blue
    end

    period '19:00'..'22:00' do
      description 'Вечерний сеанс для киноманов'
      filters year: 1900..1945 # exclude_country: 'USA'
      price 30
      hall :green
    end
  end

p theatre.periods.first.description
#theatre.buy_ticket('The Terminator')


#th = Cinema::Examples::Theatre.new('lib/movies.txt')

=begin
  nf.pay(25)
rescue StandardError => e
  puts "<#{e.class}: #{e.message}>"
=end
#nf.define_filter(:new_sci_fi) { |movie| !movie.title.include?('Terminator') && movie.genre.include?('Action') && movie.year > 2003 }
#nf.define_filter(:fav_fantasy) { |movie| movie.title.include?('Lord of the Rings') }
#nf.define_filter(:keks) { |movie, year| movie.year > year && movie.genre.include?('Action') }
#nf.show(keks: 2014)
#nf.define_filter(:newest_sci_fi, from: :keks, arg: 2014)
#nf.show(newest_sci_fi: true)
#nf.show(fav_fantasy: true)

  #nf.show(fav_fantasy: true)
  #nf.show { |movie| !movie.title.include?('Terminator') && movie.genre.include?('Action') && movie.year > 2003}
  # nf.show(actors: 'Leonardo DiCaprio') { |movie| !movie.title.include?('Terminator') && movie.genre.include?('Action') && movie.year > 2003}
#rescue StandardError => e
  #puts "<#{e.class}: #{e.message}>"
#end
#nf.show(actors: 'Leonardo DiCaprio')
#nf.show { |movie| !movie.title.include?('Terminator') && movie.genre.include?('Action') && movie.year > 2003 }
# nf.how_much?('The Kid')
#th = Cinema::Examples::Theatre.new('lib/movies.txt')
#th.buy_ticket('The Kid')
#p th.when?("The Kid")
#begin
#  th.take('Bank')
#rescue RuntimeError => e
#  puts "<#{e.class}: #{e.message}>"
#end
# begin
# 	th.when?('The Kid')
# 	rescue StandardError => e
# 		puts "<#{e.class}: #{e.message}>"
# end
#
=begin
 	th.show('15.20')
 	rescue StandardError => e
 		puts "<#{e.class}: #{e.message}>"
=end
