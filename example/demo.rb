require_relative '../lib/cinema'
require 'yaml'

using MoneyHelper

moviecollection = Cinema::MovieCollection.new('./lib/movies.txt')
p moviecollection
