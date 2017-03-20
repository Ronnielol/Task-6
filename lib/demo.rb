require_relative 'moviecollection'
require_relative 'movie'
require_relative 'netflix'
require_relative 'theatre'

nf = Netflix.new('lib/movies.txt')
begin
	nf.pay(25)
	rescue StandardError => e
		puts "<#{e.class}: #{e.message}>"
end
begin
	p nf.show(title: 'The Best Years of Our Lives')
	rescue StandardError => e
		puts "<#{e.class}: #{e.message}>"
end
#nf.how_much?('The Kid')
th = Theatre.new('lib/movies.txt')
begin
	th.when?('Tkek')
	rescue StandardError => e
		puts "<#{e.class}: #{e.message}>"
end
begin
	th.show('12.20')
	rescue StandardError => e
		puts "<#{e.class}: #{e.message}>"
end