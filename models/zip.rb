class Zip
  include Mongoid::Document
  field :code, :type => String
  field :pref, :type => String
  field :pref_en, :type => String
  field :city, :type => String
  field :city_en, :type => String
  index :code

end
