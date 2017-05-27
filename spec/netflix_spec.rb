require 'money'
require 'cinema'
require 'cinema/money_helper'

I18n.enforce_available_locales = false

describe Cinema::Examples::Netflix do
  using MoneyHelper

  let(:netflix) { described_class.new('lib/movies.txt') }

  before(:each) do
    netflix.pay(25)
  end

  context 'show' do
    it 'changes balance with movie price' do
      expect { netflix.show(title: 'The Kid') }.to change { netflix.user_balance }.from(25.to_money).to(24.to_money)
    end

    it 'shows title and description of the movie' do
      expect { netflix.show(title: 'The Kid') }.to output("Now showing The Kid\n").to_stdout
    end

    it 'raises error when balance is too low to show movie ' do
      netflix.user_balance = 1.to_money
      expect { netflix.show(title: 'Inception') }.to raise_error.with_message('Не хватает средств. Сейчас на балансе 1.00, а данный фильм стоит 5.00.')
    end

    it 'accepts filter blocks' do
      expect { netflix.show { |movie| movie.title.include?('The Lord of the Rings: The Return of the King') } }.to output("Now showing The Lord of the Rings: The Return of the King\n").to_stdout
    end

    it 'shows movie if cutsom filter enabled' do
      netflix.define_filter(:foo) { |movie| movie.title.include?('Lord of the Rings: The Return of the King') }
      expect { netflix.show(foo: true) }.to output("Now showing The Lord of the Rings: The Return of the King\n").to_stdout
    end

    xit 'raises error if custom filter disabled' do
      netflix.define_filter(:foo) { |movie| movie.title.include?('Lord of the Rings: The Return of the King') }
      expect { netflix.show(foo: false) }.to raise_error.with_message('Не найдено подходящих по фильтрам фильмов. Проверьте правильность ввода.')
    end

    it 'raises error if filter does not exist' do
      expect {  netflix.show(foobar: true)}.to raise_error.with_message("Фильтр foobar не найден. Проверьте правильность ввода.")
    end

    it 'shows movie if custom filter has parameter' do
      netflix.define_filter(:bar) { |movie, year| movie.year > year && movie.genre.include?('Action') }
      expect { netflix.show(bar: 2014) }.to output("Now showing Mad Max: Fury Road\n").to_stdout
    end
  end

  context 'pay' do
    it 'allows to refill balance' do
      expect { netflix.pay(25) }.to change { netflix.user_balance }.from(25.to_money).to(50.to_money)
    end

    it 'cant accept payments =< 0$' do
      expect { netflix.pay(-1) }.to raise_error.with_message('Нельзя пополнить счет на 0 или отрициательное значение.')
    end
  end

  context 'how_much?' do
    it 'shows movie price' do
      expect(netflix.how_much?('The Kid')).to eq(1.to_money)
    end
  end

  context 'balance' do
    it 'returns cashbox balance' do
      expect(described_class.balance).to eq(300.to_money)
    end
    it 'shares balance with class' do
      nf2 = described_class.new('lib/movies.txt')
      nf2.pay(25)
      expect(described_class.balance).to eq(350.to_money)
    end
  end

  context 'custom_filter?' do
    it 'checks if filter is custom' do
      netflix.define_filter(:fav_fantasy) { |movie| movie.title.include?('Lord of the Rings') }
      expect(netflix.send(:custom_filter?, fav_fantasy: true)).to eq(true)
      expect(netflix.send(:custom_filter?, actors: 'Arnold')).to eq(false)
    end
  end

  context 'define_filter' do
    it 'saves custom filter as a proc' do
      netflix.define_filter(:fav_fantasy) { |movie| movie.title.include?('Lord of the Rings') }
      expect(netflix.custom_filters[:fav_fantasy]).to be_a(Proc)
    end

    it 'defines new custom filter based on existing filter' do
      netflix.define_filter(:bar) { |movie, year| movie.year > year && movie.genre.include?('Action') }
      netflix.define_filter(:newest_sci_fi, from: :bar, arg: 2014)
      expect { netflix.show(newest_sci_fi: true) }.to output("Now showing Mad Max: Fury Road\n").to_stdout
    end
  end
end
