# ruby -e "Localizer.new.localize" -r ./models/localizer.rb
#
# gets names and categories from locations.csv, geolocate names and save locations.json

require 'json'
require 'geocoder'

PATH = File.expand_path "../../", __FILE__

class Localizer
  def initialize

  end

  def localize
    locations = []
    puts "geocoding...\nfailures:"
    CSV.foreach "#{PATH}/data/locations.csv" do |row|
      name, category = row[0..1]
      geo = Geocoder.search(name).first
      if geo
        locations << { name: name, category: category, lat: geo.latitude, lng: geo.longitude }
      else
        puts name
      end
    end
    puts "\n\nfinished"

    File.open "#{PATH}/data/locations.json", "w" do |file|
      file.write locations.to_json
    end
  end
end
