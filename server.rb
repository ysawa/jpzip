require "bundler"
Bundler.setup
require 'sinatra'
require 'mongoid'
require 'sinatra/reloader' if development?
require 'open-uri'
require 'zipruby'

require './config/mongoid'
Dir["./models/*.rb"].each {|file| require file }

set :haml, {:format => :html5 }
set :public, File.dirname(__FILE__) + '/public'

get '/' do
  haml :index
end

get '/import' do
  zip_path = './tmp/all.zip'
  open(zip_path, 'w') do |output|
    open(Jpzip::PREF_ALL) do |data|
      output.write(data.read)
    end
  end
  Jpzip.delete_all
  Jpzip.import!(zip_path)
  FileUtils.rm(zip_path)
  "ok"
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
