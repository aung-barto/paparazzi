require 'sinatra'
require 'sqlite3'
require 'pry'
require 'httparty'
require 'json'

db = SQLite3::Database.new "insta.db"

rows = db.execute <<-SQL
create table if not exists instas (
	id INTEGER PRIMARY KEY, 
	tag TEXT, 
	img_url TEXT
	); 
SQL


get '/' do 
	insta_list = db.execute("SELECT * FROM instas")
	erb :main, locals: {insta: insta_list}
end 

get '/search' do 
	
	tag = params[:tag]
	
	keyfile = JSON.parse(File.read('secrets.json'))
	key =keyfile["apikey"]
	location = params[:location]
	#if location box is checked
	if location == "on"
		address = params[:tag].gsub("/\s/", "+")
		data = HTTParty.get("https://maps.googleapis.com/maps/api/geocode/json?address=#{address}")
		
		lat = data["results"][0]["geometry"]["location"]["lat"]
		lng = data["results"][0]["geometry"]["location"]["lng"]

		response = HTTParty.get("https://api.instagram.com/v1/media/search?lat=#{lat}&lng=#{lng}&count=10&client_id=#{key}")
		parsed_body = JSON.parse(response.body)
		results = parsed_body["data"]
		url_arr = []
		results.each do |item|
			url_arr << item["images"]["standard_resolution"]["url"]
		end
		erb :search, locals: {results: url_arr, tag: tag}

	else
		response = HTTParty.get("https://api.instagram.com/v1/tags/#{tag}/media/recent?&count=10&client_id=#{key}")
		
		parsed_body = JSON.parse(response.body)
		results = parsed_body["data"]
		url_arr = []
		results.each do |item|
			url_arr << item["images"]["standard_resolution"]["url"]
		end 
		erb :search, locals: {results: url_arr, tag: tag}
	end
end 

post '/' do 
	tag = params[:tag]
	# gets rid of the first element 
	params.shift
	params.each do |key, value|
		db.execute("INSERT INTO instas (tag, img_url) values (?,?);", tag, value)
	end 
	redirect("/")
end  

get '/pics/:id' do 
	id = params[:id]
	one_pic = db.execute("SELECT * FROM instas WHERE id = ?", id)
	erb :show, locals: {pic: one_pic[0]}
end

delete '/pics/:id' do
	id = params[:id]
	db.execute("DELETE FROM instas WHERE id = ?", id)
	redirect("/")
end

get '/tags/:tag' do 
	tag = params[:tag]
	pic_list = db.execute("SELECT * FROM instas WHERE tag = ?", tag)
	erb :tags, locals: {results: pic_list, tag: tag}
end 













