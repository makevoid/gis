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
        next if name =~ /_refuseds/
        next if name =~ /_good/
      end
      localize_name name
    end
  end

  private

  def localize_name(name)
    locations = []
    refuseds = []
    good = []
    puts "geocoding #{name}:\nfailures:"
    idx = 0
    CSV.foreach("#{PATH}/data/#{name}.csv", { col_sep: ";" }) do |row|
      idx += 1
      next if idx == 1
      loc_name, category, project_id, cris_id = row
      geo = Geocoder.search(loc_name).first
      if geo
        good << row.join(";")
        locations << { name: loc_name, category: category, lat: geo.latitude, lng: geo.longitude, project_id: project_id, cris_id: cris_id }
      else
        refuseds << row.join(";")
        map_url = "https://maps.google.com/maps?q=#{loc_name.gsub("\s", "+")}" if loc_name
        puts "f> #{loc_name} > #{map_url}"
      end
      sleep 0.15
    end
    File.open("#{PATH}/data/#{name}_good.csv", "w"){ |f| f.write good.join("\n") } unless good.empty?
    File.open("#{PATH}/data/#{name}_refuseds.csv", "w"){ |f| f.write refuseds.join("\n") } unless refuseds.empty?
    puts "\n\nfinished - real geocoding api: http://code.google.com/apis/ajax/playground/#geocoding_simple"

    File.open "#{PATH}/data/#{name}.json", "w" do |file|
      file.write locations.to_json
    end
  end
end
