require_relative 'moviecollection'
require_relative 'movie'
require_relative 'netflix'
require_relative 'theatre'

nf = Netflix.new('lib/movies.txt')
nf.pay(10)
begin
	nf.show(period: :ancient)
	rescue StandardError => e
		puts "<#{e.class}: #{e.message}>"
end
#nf.how_much?('The Kid')
#th = Theatre.new('lib/movies.txt')
#th.when?('The Kid')
#th.show('15.20')