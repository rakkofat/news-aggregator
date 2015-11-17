
require 'pry'
require 'sinatra'
require 'csv'
require_relative 'lib/article.rb'

set :public_folder, File.join(File.dirname(__FILE__), "public")

use Rack::Session::Cookie, {
  expire_after: 30000
}

def article_setup
  article_setup = []
  CSV.foreach("articles.csv") do |row|
    article_setup << Article.new(row[0], row[1], row[2])
  end
  article_setup
end

get '/' do
  erb :homepage
end

get '/articles' do
  @article_array = article_setup
  erb :articles
end

get '/articles/new' do
  # @error = params[:error]

  if session[:error]
    @title = session[:title]
    @url = session[:url]
    @description = session[:description]
  end
  erb :new
end

post '/articles' do
  article_title = params[:title]
  article_url = params[:url]
  article_description = params[:description]
  destination = ""

  CSV.foreach("articles.csv") do |row|
    if article_url == row[1]
      session[:error] = true
      session[:title] = article_title
      session[:url] = article_url
      session[:description] = article_description
      redirect "/articles/new"
    end
  end

  CSV.open("articles.csv", "ab") do |csv|
    csv << [article_title, article_url, article_description]
  end

  redirect "/articles"
end
