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
  Jpzip.delete_all
  @list = Jpzip.import_list
  haml :import
end

get '/import/:zip_file' do |zip_file|
  zip_path = "./tmp/" + zip_file
  if (!File.exist?(zip_path) || Time.now - File.mtime(zip_path) >= 86400)
    open(zip_path, 'w') do |output|
      open(Jpzip::LIST_DIRECTORY + zip_file) do |data|
        output.write(data.read)
      end
    end
  end
  Jpzip.import!(zip_path)
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
