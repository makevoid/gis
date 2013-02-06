# encoding: utf-8
path = File.expand_path '../', __FILE__
PATH = path

require "#{path}/config/env.rb"

class Gis < Sinatra::Base
  include Voidtools::Sinatra::ViewHelpers

  # partial :comment, { comment: "blah" }
  # partial :comment, comment

  def partial(name, value={})
    locals = if value.is_a? Hash
      value
    else
      hash = {}; hash[name] = value
      hash
    end
    haml "_#{name}".to_sym, locals: locals
  end
end

LOCATION_NAMES = Dir.glob("#{PATH}/data/*.csv").map{ |file| File.basename file, ".csv" }

def read_locations
  locs = {}
  for loc in LOCATION_NAMES
    locs[loc.to_sym] = File.open("#{PATH}/data/#{loc}.json", "r:UTF-8").read
  end
  locs
end

class Gis < Sinatra::Base

  LOCATIONS = read_locations

  get "/" do
    @data_name = "a"
    haml :index
  end

  get "/*.json" do |loc_name|
    name = File.basename loc_name
    data = LOCATIONS[name.to_sym]

    content_type :json
    halt 404, "{ \"error\": \"not found\", message: \"Location #{data} not found, maybe you mistyped the url\" }" unless data
    data
  end

  get "/*" do |loc_name|
    @data_name = loc_name
    haml :index
  end
end

require_all "#{path}/routes"