require 'money'
require 'cinema'
require 'cinema/money_helper'
require 'csv'

describe Cinema::Cashbox do
  using MoneyHelper

  let(:dummy_cashbox) { Class.new.extend(Cinema::Cashbox) }

  context 'replenish balance' do
    it 'adds money to cashbox' do
      expect { dummy_cashbox.replenish_balance(25) }.to change { dummy_cashbox.balance }.from(0.to_money).to(25.to_money)
    end
  end

  context 'balance' do
    it 'returns current cashbox balance' do
      expect(dummy_cashbox.balance).to eq(0.to_money)
    end
  end

  context 'take' do
    it 'set cashbox balance to zero' do
      dummy_cashbox.replenish_balance(25)
      expect { dummy_cashbox.take('Bank') }.to change { dummy_cashbox.balance }.from(25.to_money).to(0.to_money)
    end
    it 'raises error if argument is not Bank' do
      expect { dummy_cashbox.take('robber') }.to raise_error.with_message('Вы не банк! Вызываем полицию!')
    end
  end
end
