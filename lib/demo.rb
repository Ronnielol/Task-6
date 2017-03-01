require_relative 'moviecollection'
require_relative 'movie'
require_relative 'netflix'
require_relative 'theatre'

nf = Netflix.new('movies.txt')
nf.pay(10)
begin
	nf.show(period: :new, genre: 'Comedy')
	rescue StandardError => e
		puts "<#{e.class}: #{e.message}>"
end

th = Theatre.new('movies.txt')
th.show('11.20')