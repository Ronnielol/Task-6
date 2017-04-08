require 'money'	
require 'csv'
require_relative 'modules/cashbox_implementation'
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
nf.user_balance
begin
	nf.show(actors: 'Arnold Schwarzenegger')
	rescue StandardError => e
		puts "<#{e.class}: #{e.message}>"
end
#nf.how_much?('The Kid')
th = Theatre.new('lib/movies.txt')
th.buy_ticket('The Kid')
th.cash
begin
	th.take('Bank')
rescue RuntimeError => e
	puts "<#{e.class}: #{e.message}>"
end
=begin
begin
	th.when?('The Kid')
	rescue StandardError => e
		puts "<#{e.class}: #{e.message}>"
end

begin
	th.show('15.20')
	rescue StandardError => e
		puts "<#{e.class}: #{e.message}>"
end
=end