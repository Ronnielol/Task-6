require 'cinema'

describe Cinema::Examples::Period do
  subject {
    described_class.new('10:00'..'16:00') do
      description 'Спецпоказ'
      title 'The Terminator'
      price 50
      hall :green, :blue
    end
  }

  let(:filter_method) {
    described_class.new('10:00'..'16:00') do
      description 'Спецпоказ'
      filters genre: ['Action', 'Drama'], year: 2007..Time.now.year
      price 50
      hall :green, :blue
    end
  }

  context 'description' do
    its(:description) { is_expected.to eq('Спецпоказ') }
  end

  context 'time' do
    its(:time) {is_expected.to eq('10:00'..'16:00')}
  end

  context 'price' do
    its(:price) {is_expected.to eq(50)}
  end

  context 'hall' do
    its(:hall) {is_expected.to eq([:green, :blue])}
  end

  context 'filters' do
    it 'returns given filter' do
      expect(filter_method.filters).to eq(genre: ['Action', 'Drama'], year: 2007..Time.now.year)
    end
  end

  context 'method_missing' do
    it 'creates fitlers method depending on block if no filter given' do
      expect(subject.filters).to eq(title: "The Terminator")
    end
  end
end