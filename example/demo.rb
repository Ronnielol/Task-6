require_relative '../lib/cinema'
require 'yaml'

using MoneyHelper

moviecollection = Cinema::MovieCollection.new('./lib/movies.txt')
parser = Cinema::Parser.new(moviecollection)
parser.save_to_yml
parser.save_to_html

# yml_structure = data.to_yaml
# File.open("data.yml", "w") do |file|
#   file.puts yml_structure
# end