
$:.unshift File.expand_path( "..", __FILE__)

# require "lib/app"
require "pizzaAnalytics"
require "rack"

# RACK
	# run Proc.new { |env| ['200', {'Content-Type' => 'text/html'}, ['Hey Puppies']] }
	run App::App.new
	# run Start.new
