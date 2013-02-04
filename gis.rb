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


def read_locations
  json = File.read "#{PATH}/data/locations.json"
  JSON.parse json
end

class Gis < Sinatra::Base

  LOCATIONS = read_locations

  get "/" do
    haml :index
  end

  get "/locations" do
    File.read "#{PATH}/data/locations.json"
    # out = ""
    # LOCATIONS.each do |location|
    #   out << ""
    # end
    # out
  end
end

require_all "#{path}/routes"