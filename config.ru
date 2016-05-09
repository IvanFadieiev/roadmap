#\ -p 3000
require 'faker'
require 'figaro'

config = YAML.load(File.read(File.expand_path('config/application.yml')))
config.merge! config.fetch(Rails.env,{})
config.each do|key,value|
	ENV[key] = value.to_s
end

#run proc { |env| [ 200, {'Content-Type' => 'text/plain'}, ["#{Faker::Lorem.sentence}"] ] }


Rack::Server.start(
  :app => lambda do |e|
    [200, {'Content-Type' => 'text/html'}, ["#{Faker::Lorem.sentence}, figaro: #{ENV['KEY']}"]]
  end,
  :server => "#{ENV["SERVER"]}"
)
