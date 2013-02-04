class Sig < Sinatra::Base
  get "/" do
    haml :index
  end
end