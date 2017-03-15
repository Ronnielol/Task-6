require_relative 'moviecollection'
require_relative 'movie'
require_relative 'netflix'
require_relative 'theatre'

nf = Netflix.new('lib/movies.txt')
begin
	nf.pay(0)
	rescue StandardError => e
		puts "<#{e.class}: #{e.message}>"
end
begin
	p nf.show(title: 'Persona')
	rescue StandardError => e
		puts "<#{e.class}: #{e.message}>"
end
#nf.how_much?('The Kid')
#th = Theatre.new('lib/movies.txt')
#th.when?('Gone with the Wind')
#th.show('15.20')