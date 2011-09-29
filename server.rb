require 'sinatra'
require 'sinatra/reloader' if development?
require 'haml'
require 'sass'

set :haml, {:format => :html5 }

get '/zips/:id' do |zip|
  "Hello zip:#{zip}!"
  #haml 'zips/index'
end

get '/zips' do
  haml 'zips/index'
end

get '/' do
  haml :index
end

