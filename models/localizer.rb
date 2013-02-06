# ruby -e "Localizer.new.localize" -r ./models/localizer.rb
#
# gets names and categories from locations.csv, geolocate names and save locations.json

require 'json'
require 'geocoder'

PATH = File.expand_path "../../", __FILE__

class NullName
end

class Localizer
  def initialize(names=NullName.new)
    @names = [names].flatten
  end

  def localize
    names = Dir.glob("#{PATH}/data/*.csv").map{ |file| File.basename file, ".csv" }

    for name in names
      unless @names.first.is_a? NullName
        next unless @names.include? name.to_s
      end
      localize_name name
    end
  end

  private

  def localize_name(name)
    locations = []
    puts "geocoding #{name}:\nfailures:"
    idx = 0
    CSV.foreach("#{PATH}/data/#{name}.csv", { col_sep: ";" }) do |row|
      idx += 1
      next if idx == 1
      project_id, cris_id, loc_name, category = row
      geo = Geocoder.search(loc_name).first
      if geo
        locations << { name: loc_name, category: category, lat: geo.latitude, lng: geo.longitude, project_id: project_id, cris_id: cris_id }
      else
        puts loc_name
      end
      sleep 0.15
    end
    puts "\n\nfinished"

    File.open "#{PATH}/data/#{name}.json", "w" do |file|
      file.write locations.to_json
    end
  end
end
