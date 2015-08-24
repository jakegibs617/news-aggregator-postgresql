require 'sinatra'
require 'pry'
require "pg"
require "csv"

def db_connection
  begin
    connection = PG.connect(dbname: "news_aggregator_development")
    yield(connection)
  ensure
    connection.close
  end
end

# db_connection do |conn|
#   conn.exec_params("DELETE FROM articles")
# end

db_connection do |conn|
  list = conn.exec_params("SELECT name, url, description FROM articles")
  list.each do |article|
     "#{article["name"]}: #{article["url"]}:: #{article["description"]}"
  end
end

get "/articles" do
	db_connection do |conn|
		list = conn.exec_params("SELECT name, url, description FROM articles")
		erb :shows, locals: { list: list }
	end
end

get "/articles/new" do
	db_connection do |conn|
		list = conn.exec_params("SELECT name, url, description FROM articles")
		erb :form, locals: { list: list }
	end
end

post '/articles/new' do

	db_connection do |conn|
		list = conn.exec_params("SELECT url FROM articles")
		redirect '/error.html' if list.values.flatten.include?(params["url"])
	end

	db_connection do |conn|
    conn.exec_params("INSERT INTO articles (name, url, description) VALUES ($1, $2, $3)", [params['title'],params['url'],params['description']])
	end
  redirect '/articles'

end
