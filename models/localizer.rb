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

  def write_files(name, good, locations, refuseds)
    # File.open("#{PATH}/data/#{name}_good.csv", "w"){ |f| f.write good.join("\n") } unless good.empty?
    # File.open("#{PATH}/data/#{name}_refuseds.csv", "w"){ |f| f.write refuseds.join("\n") } unless refuseds.empty?
    File.open "#{PATH}/data/#{name}.json", "w" do |file|
      file.write locations.to_json
    end
  end

  COL_SEP = ";"

  private

  def log_failure loc_name, project_title
    map_url = "https://maps.google.com/maps?q=#{loc_name.gsub("\s", "+")}" if loc_name
    map_url2 = "https://maps.google.com/maps?q=#{project_title.gsub("\s", "+")}" if project_title
    puts "f> #{loc_name} > #{map_url}\n#{project_title} > #{map_url2}\n"
  end

  def localize_name(name)
    locations = []
    refuseds = []
    good = []
    puts "geocoding #{name}:\nfailures:"
    idx = 0
    CSV.foreach("#{PATH}/data/#{name}.csv", { col_sep: COL_SEP }) do |row|
      idx += 1
      next if idx == 1

      loc_name, category, project_id, cris_id, project_title = row
      geo_field = "name"
      geo = Geocoder.search(loc_name).first

      location = { name: loc_name, category: category, project_id: project_id, cris_id: cris_id, project_title: project_title, geo_field: geo_field }

      if geo
        # row += [project_title, geo.latitude, geo.longitude]
        # good << row.join(COL_SEP)
        locations << location.merge( lat: geo.latitude, lng: geo.longitude )
      else
        geo2 = Geocoder.search(project_title).first
        if geo2
          locations << location.merge( lat: geo2.latitude, lng: geo2.longitude )
        else
          refuseds << row.join(COL_SEP)
          log_failure loc_name, project_title
        end
      end

      sleep 0.5
    end

    write_files name, good,  locations, refuseds

    puts "\n\nfinished!\ngood: #{locations.size}, refuseds: #{refuseds.size}"
    # real geocoding api: http://code.google.com/apis/ajax/playground/#geocoding_simple
  end
end
