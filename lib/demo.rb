require 'money'	
require 'csv'
require_relative 'cinema'

nf = Cinema::Examples::Netflix.new('lib/movies.txt')

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
th = Cinema::Examples::Theatre.new('lib/movies.txt')
th.buy_ticket('The Kid')
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