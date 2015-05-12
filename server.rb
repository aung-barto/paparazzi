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

#search images
get '/search' do 
	tag = params[:tag]
	
	keyfile = JSON.parse(File.read('secrets.json'))
	insta_key =keyfile["instaKey"]
	weather_key = keyfile["weatherKey"]

	location = params[:location]
	#if location box is checked
	if location == "on"
		address = params[:tag].gsub("/\s/", "+")
		data = HTTParty.get("https://maps.googleapis.com/maps/api/geocode/json?address=#{address}")
		
		lat = data["results"][0]["geometry"]["location"]["lat"]
		lng = data["results"][0]["geometry"]["location"]["lng"]

		weather_data = HTTParty.get("http://api.wunderground.com/api/#{weather_key}/hourly/q/#{lat},#{lng}.json")
		temp = weather_data["hourly_forecast"][0]["feelslike"]["english"].to_i
		color_arr = ["#43A7EF","#549CDC","#6591C9","#7787B6","#887CA3","#9A7290","#AB677D","#BC5C6A","#CE5257","#DF4744"]
		index = (temp/10).to_f - 1
		background_color = color_arr[index]

		response = HTTParty.get("https://api.instagram.com/v1/media/search?lat=#{lat}&lng=#{lng}&count=10&client_id=#{insta_key}")
		parsed_body = JSON.parse(response.body)
		results = parsed_body["data"]
		url_arr = []
		results.each do |item|
			url_arr << item["images"]["standard_resolution"]["url"]
		end
		erb :search, locals: {results: url_arr, tag: tag, color: background_color}

	else
		response = HTTParty.get("https://api.instagram.com/v1/tags/#{tag}/media/recent?&count=10&client_id=#{insta_key}")
		
		parsed_body = JSON.parse(response.body)
		results = parsed_body["data"]
		url_arr = []
		results.each do |item|
			url_arr << item["images"]["standard_resolution"]["url"]
		end 
		erb :search, locals: {results: url_arr, tag: tag, color: "#ffffff"}
	end
end 

#add image and tag name into database
post '/' do 
	tag = params[:tag]
	# gets rid of the first element 
	params.shift
	params.each do |key, value|
		db.execute("INSERT INTO instas (tag, img_url) values (?,?);", tag, value)
	end 
	redirect("/")
end  

#show individual image
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

#show images by tag name
get '/tags/:tag' do 
	tag = params[:tag]
	pic_list = db.execute("SELECT * FROM instas WHERE tag = ?", tag)
	erb :tags, locals: {results: pic_list, tag: tag}
end














