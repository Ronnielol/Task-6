require 'moviecollection'
require 'movie'

describe AncientMovie do

	let(:nf) {Netflix.new('lib/movies.txt')}

	context 'description' do
		it 'shows ancient movie description' do
			nf.pay(10)
			nf.show(period: :ancient)
			expect{nf.show(period: :ancient)}.to output(/старый фильм/).to_stdout
		end
	end

	context 'initialize' do 
		it 'creates object with class AncientMovie if movie year < 1945' do 
			expect(nf.filter(:title, 'Laura')[0].class).to eq(AncientMovie)
		end
	end
end

describe ClassicMovie do

	let(:nf) {Netflix.new('lib/movies.txt')}

	context 'description' do
		it 'shows classic movie description' do
			nf.pay(10)
			nf.show(period: :classic)
			expect{nf.show(period: :classic)}.to output(/классический фильм/).to_stdout
		end
	end

	context 'initialize' do 
		it 'creates object with class ClassicMovie if movie year >= 1945 and < 1968' do 
			expect(nf.filter(:title, 'The Graduate')[0].class).to eq(ClassicMovie)
		end
	end
end

describe ModernMovie do

	let(:nf) {Netflix.new('lib/movies.txt')}

	context 'description' do
		it 'shows modern movie description' do
			nf.pay(10)
			nf.show(period: :modern)
			expect{nf.show(period: :modern)}.to output(/современное кино/).to_stdout
		end
	end

	context 'initialize' do 
		it 'creates object with class ModernMovie if movie year >= 1946 and < 2000' do 
			expect(nf.filter(:title, 'Fight Club')[0].class).to eq(ModernMovie)
		end
	end
end

describe NewMovie do

	let(:nf) {Netflix.new('lib/movies.txt')}
	
	context 'description' do
		it 'shows new movie description' do
			nf.pay(10)
			nf.show(period: :new)
			expect{nf.show(period: :new)}.to output(/новинка/).to_stdout
		end
	end

	context 'initialize' do 
		it 'creates object with class NewMovie if movie year >= 2000 til today' do 
			expect(nf.filter(:title, 'Memento')[0].class).to eq(NewMovie)
		end
	end
end