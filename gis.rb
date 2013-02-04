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


def read_locations
  File.open("#{PATH}/data/locations.json", "r:UTF-8").read
end

class Gis < Sinatra::Base

  LOCATIONS = read_locations

  get "/" do
    haml :index
  end

  get "/locations" do
    LOCATIONS
  end
end

require_all "#{path}/routes"