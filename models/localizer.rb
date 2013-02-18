# ruby -e "Localizer.new.localize" -r ./models/localizer.rb
#
# gets names and categories from locations.csv, geolocate names and save locations.json

require 'json'
require 'geocoder'
require 'google_drive'

PATH = File.expand_path "../../", __FILE__

require "#{PATH}/config/fields"

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


class Csvr

  def read(path)
    csv = CSV.read path
    to_ruby csv
  end

  def to_ruby(all)
    head = all[0]
    table = all[1..-1]
    results = []
    for column in table
      hash = {}
      column.each_with_index do |row, idx|
        hash[head[idx]] = row
      end
      results << hash
    end
    results
  end

end

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

  ASSOC_FIELD = "CONTRACT_N"


  # FIELDS removeds = PHY_RSC

  def assoc
    assoc = Csvr.new.read "#{PATH}/data/assoc/assoc.csv"
    data = JSON.parse File.read "#{PATH}/data/a2.json"

    data.each_with_index do |obj, idx|
      asso = assoc.find{ |as| as[ASSOC_FIELD] == obj["project_number"] }
      next unless asso
      # p asso[ASSOC_FIELD]

      for field in FIELDS
        field = field.to_sym
        value = asso.fetch field.upcase.to_s
        obj[field] = value
      end
    end

    data2 = {}

    associations = ["Associations - Color: Theme"]

    nil_color = "pink"
    colors = %w(red green blue yellow dark_green light_blue)

    for field in FIELDS2
      types = data.map{ |obj| obj[field] }.uniq.compact

      description = types.map.with_index do |type, idx|
        type = "null" if type.blank?
        "#{type}: #{colors[idx]}"
      end.join(", ")
      associations << "#{field}: #{description}"

      for obj in data
        value = obj[field]
        color = nil_color
        if value
          type = types.index value
          color = colors.fetch(type)
        end
        obj[field] = color
      end
    end

    puts associations.join("\n")

    File.open("#{PATH}/data/a.json", "w") do |file|
      file.write data.to_json
    end
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


