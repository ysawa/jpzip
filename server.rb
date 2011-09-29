require 'sinatra'
require 'sinatra/reloader' if development?
require 'haml'
require 'sass'
require 'mongoid'

Mongoid.configure do |config|
  config.master = Mongo::Connection.new.db('jpzip')
end

Dir["./models/*.rb"].each {|file| require file }

set :haml, {:format => :html5 }

get '/*.*' do |code, format|
  code.gsub! /\D/, ''
  "Hello zip:#{code}.#{format}!"
  #haml 'zips/index'
end

get '/' do
  haml :index
end

