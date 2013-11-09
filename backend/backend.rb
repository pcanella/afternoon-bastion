require 'sinatra'
require './Database'

get '/databases' do
  d = Database.new
  test = d.connect("maps_db")
  "<div style='background-color:green'>Hello World!</div> #{d.getAllLocations(test)}"
end