require_relative '../lib/cinema'

using MoneyHelper

nf = Cinema::Examples::Netflix.new('lib/movies.txt')

begin
  nf.pay(25)
rescue StandardError => e
  puts "<#{e.class}: #{e.message}>"
end
#nf.define_filter(:new_sci_fi) { |movie| !movie.title.include?('Terminator') && movie.genre.include?('Action') && movie.year > 2003 }
nf.define_filter(:fav_fantasy) { |movie| movie.title.include?('Lord of the Rings') }
nf.define_filter(:keks) { |movie, year| movie.year > year && movie.genre.include?('Action') }
#nf.show(keks: 2014)
nf.define_filter(:newest_sci_fi, from: :keks, arg: 2014)
nf.show(newest_sci_fi: true)
#nf.show(fav_fantasy: true)

  #nf.show(fav_fantasy: true)
  #nf.show { |movie| !movie.title.include?('Terminator') && movie.genre.include?('Action') && movie.year > 2003}
  # nf.show(actors: 'Leonardo DiCaprio') { |movie| !movie.title.include?('Terminator') && movie.genre.include?('Action') && movie.year > 2003}
#rescue StandardError => e
  #puts "<#{e.class}: #{e.message}>"
#end
nf.show(actors: 'Leonardo DiCaprio')
#nf.show { |movie| !movie.title.include?('Terminator') && movie.genre.include?('Action') && movie.year > 2003 }
# nf.how_much?('The Kid')
th = Cinema::Examples::Theatre.new('lib/movies.txt')
th.buy_ticket('The Kid')
begin
  th.take('Bank')
rescue RuntimeError => e
  puts "<#{e.class}: #{e.message}>"
end
# begin
# 	th.when?('The Kid')
# 	rescue StandardError => e
# 		puts "<#{e.class}: #{e.message}>"
# end
#
# begin
# 	th.show('15.20')
# 	rescue StandardError => e
# 		puts "<#{e.class}: #{e.message}>"
# end
# =
