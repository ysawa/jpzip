require "bundler"
Bundler.setup
require 'sinatra'
require 'mongoid'
require 'sinatra/reloader' if development?
require 'open-uri'
require 'zipruby'

Mongoid.configure do |config|
  config.master = Mongo::Connection.new.db('jpzip')
end

Dir["./models/*.rb"].each {|file| require file }

set :haml, {:format => :html5 }

get '/' do
  haml :index
end

get '/import' do
  zippath = './tmp/all.zip'
  #open(zippath, 'w') do |output|
  #  open(Jpzip::PREF_ALL) do |data|
  #    output.write(data.read)
  #  end
  #end
  Jpzip.delete_all
  Jpzip.import!(zippath)
end

get '/import/rome' do
  zippath = './tmp/all_rome.zip'
  #open(zippath, 'w') do |output|
  #  open(Jpzip::PREF_ALL_ROME) do |data|
  #    output.write(data.read)
  #  end
  #end
  Jpzip.import_rome!(zippath)
end

get '/*.*' do |code, format|
  code.gsub! /\D/, ''
  jpzip = Jpzip.where(:code => code).first
  return 404 unless jpzip
  attrs = jpzip.attributes
  attrs.delete("_id")
  case format
  when "xml"
    attrs.to_xml
  when "json"
    attrs.to_json
  else
    403
  end
end

not_found do
  "Not Found"
end

error 403 do
  "Invalid Format"
end
