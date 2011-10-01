require 'csv'
require 'kconv'

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

  PREF_ALL = 'http://www.post.japanpost.jp/zipcode/dl/kogaki/zip/ken_all.zip';
  PREF_ALL_ROME = "http://www.post.japanpost.jp/zipcode/dl/roman/ken_all_rome.zip";

  def self.convert_encoding(string)
    string.force_encoding("Windows-31J").kconv(Kconv::UTF8, Kconv::SJIS)
  end

  def self.import!(zippath)
    Zip::Archive.open(zippath) do |archive|
      archive.num_files.times do |i|
        archive.fopen(archive.get_name(i)) do |f|
          if f.name =~ /\.csv$/i
            file = File.open(File.dirname(zippath) + "/" + f.name, 'w')
            file.write(f.read)
            file.close
            CSV.foreach(f.name) do |row|
              jpzip = Jpzip.new
              jpzip.code = row[2]
              jpzip.pref_kana = self.convert_encoding(row[3])
              jpzip.city_kana = self.convert_encoding(row[4])
              jpzip.pref = self.convert_encoding(row[6])
              jpzip.city = self.convert_encoding(row[7])
              jpzip.save
            end
          end
        end
      end
    end
  end

  def self.import_rome!(zippath)
    Zip::Archive.open(zippath) do |archive|
      archive.num_files.times do |i|
        archive.fopen(archive.get_name(i)) do |f|
          if f.name =~ /\.csv$/i
            file = File.open(f.name, 'w')
            file.write(f.read)
            file.close
            CSV.foreach(f.name) do |row|
              jpzip = Jpzip.new
              jpzip.code = row[2]
              jpzip.pref_kana = row[6]
              jpzip.city_kana = row[7]
              jpzip.pref = row[6]
              jpzip.city = row[7]
              return row.force_encoding("Windows-31J").encode("UTF-8")
            end
          end
        end
      end
    end
  end
end
