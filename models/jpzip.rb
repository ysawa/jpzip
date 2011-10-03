require 'csv'
require 'kconv'
require 'fileutils'

class Jpzip
  include Mongoid::Document
  include Mongoid::Timestamps
  field :code, :type => String
  field :pref, :type => String
  field :pref_kana, :type => String
  field :pref_rome, :type => String
  field :city, :type => String
  field :city_kana, :type => String
  field :city_rome, :type => String
  index :code

  LIST_DIRECTORY = 'http://www.post.japanpost.jp/zipcode/dl/kogaki/zip/'
  LIST_ROME_DIRECTORY = 'http://www.post.japanpost.jp/zipcode/dl/roman/'

  def out
    attrs = self.attributes
    attrs.delete("_id")
    attrs.delete("created_at")
    attrs
  end

  def self.convert_encoding(string)
    string.force_encoding("Windows-31J").kconv(Kconv::UTF8, Kconv::SJIS)
  end

  def self.import_list
    YAML.load_file(File.dirname(__FILE__) + "/../config/list.yml")
  end

  def self.import_list_rome
    YAML.load_file(File.dirname(__FILE__) + "/../config/list_rome.yml")
  end

  def self.import!(zip_path)
    Zip::Archive.open(zip_path) do |archive|
      archive.num_files.times do |i|
        archive.fopen(archive.get_name(i)) do |f|
          if f.name =~ /\.csv$/i
            csv_path = File.dirname(zip_path) + "/" + f.name
            file = File.open(csv_path, 'w')
            file.write(f.read)
            file.close
            CSV.foreach(csv_path) do |row|
              code = row[2]
              jpzip = Jpzip.new
              jpzip.code = code
              jpzip.pref_kana = self.convert_encoding(row[3])
              jpzip.city_kana = self.convert_encoding(row[4])
              jpzip.pref = self.convert_encoding(row[6])
              jpzip.city = self.convert_encoding(row[7])
              jpzip.save
            end
            FileUtils.rm(csv_path)
          end
        end
      end
    end
  end
end
