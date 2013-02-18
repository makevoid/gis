# ruby -e "Localizer.new.localize" -r ./models/localizer.rb
#
# gets names and categories from locations.csv, geolocate names and save locations.json

require 'json'
require 'geocoder'
require 'google_drive'

# monkeypatches

class String
  def blank?
    self == ""
  end
end

class NilClass
  def blank?
    true
  end
end

# new feature:
#
# GoogleDrive::Worksheet#to_ruby
# GoogleDrive::Worksheet#load_ruby [{a: "b"}, {...]

class GoogleDrive::Worksheet
  def to_ruby
    array = []
    keys = []

    # TODO: use this, it seems faster
    # p rows

    for col in 1..num_cols
      keys << self[1, col]
    end

    for row in 2..num_rows
      hash = {}

      for col in 1..num_cols
        key = keys[col-1]
        hash[key.to_sym] = self[row, col]
      end
      array << hash
    end
    array
  end

  def load_ruby(array)

    keys = array.first.keys

    keys.each_with_index do |key, idx|
      self[1, idx+1] = key
    end

    array.each_with_index do |hash, idx|
      for col in 1..num_cols
        self[idx+2, col] = hash[keys[col-1]]
      end
    end

    save
  end

  def delete_and_remake
    spreadsheet.add_worksheet "spreadsheet"
    delete
    spreadsheet.worksheets[0]
  end
end



PATH = File.expand_path "../../", __FILE__

class NullName
end

class Localizer
  def initialize(names=NullName.new)
    Geocoder.configure timeout: 10
    @names = [names].flatten
  end

  def localize
    session = GoogleDrive.login "m4kevoid@gmail.com", "finalman"
    spreadsheet = session.spreadsheet_by_key "0An6PEgBOu3TwdHZZNVMtNXBsR0ttR3BqaHI4cVllMEE"
    @ws = spreadsheet.worksheets[0]


    localize_one
  end

  private

  def localize_one

    rows = @ws.to_ruby

    rows.each do |row|
      lat, lng = nil, nil
      next unless row[:lat].blank?
      geo = Geocoder.search(row[:location_name]).first

      if geo
        lat, lng = geo.latitude, geo.longitude
      else
        sleep 2
        geo = Geocoder.search(row[:project_title]).first
        if geo
          lat, lng = geo.latitude, geo.longitude
        end
      end
      row.merge! lat: lat, lng: lng

      sleep 2
    end

    @ws = @ws.delete_and_remake
    @ws.load_ruby rows

    File.open "#{PATH}/data/a.json", "w" do |file|
      file.write rows.to_json
    end
    puts "\n\nfinished!"
    # real geocoding api: http://code.google.com/apis/ajax/playground/#geocoding_simple
  end
end


