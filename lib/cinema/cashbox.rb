module Cinema
  # Cashbox module adds balance and balance methods to object
  module Cashbox
    using MoneyHelper

    def replenish_balance(amount)
      @cashbox_balance = balance + amount.to_money
    end

    def balance
      @cashbox_balance ||= 0.to_money
    end

    def take(who)
      raise 'Вы не банк! Вызываем полицию!' if who != 'Bank'
      @cashbox_balance = 0.to_money
      puts 'Проведена инкассация.'
    end
  end
end
