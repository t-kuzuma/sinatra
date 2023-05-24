# frozen_string_literal: true

require 'sinatra'
require 'sinatra/contrib'
require 'sinatra/reloader'
require 'json'
require 'cgi'

FILE_PATH = 'public/memos.json'

def get_memos_data(file_path)
  File.open(file_path, 'r') do |file|
    JSON.parse(file.read)
  end
end

def set_memos_data(file_path, memos)
  File.open(file_path, 'w') do |file|
    file.write(JSON.generate(memos))
  end
end

get '/memos' do
  @memos = get_memos_data(FILE_PATH)
  erb :top
end

get '/memos/new' do
  erb :new
end

get '/memos/:id' do
  memos = get_memos_data(FILE_PATH)
  @memo = memos[params[:id]]
  erb :show
end

post '/memos' do
  memos = get_memos_data(FILE_PATH)
  new_memos_id = memos.keys.map(&:to_i).max + 1
  memos[new_memos_id.to_s] = {
    'title' => params[:title],
    'content' => params[:content]
  }
  set_memos_data(FILE_PATH, memos)
  redirect '/memos'
end

get '/memos/:id/edit' do
  @memos = get_memos_data(FILE_PATH)
  erb :edit
end

patch '/memos/:id' do
  memos = get_memos_data(FILE_PATH)
  memos[params[:id]] = {
    'title' => params[:title],
    'content' => params[:content]
  }
  set_memos_data(FILE_PATH, memos)
  redirect '/memos'
end

delete '/memos/:id' do
  memos = get_memos_data(FILE_PATH)
  memos.delete(params[:id])
  set_memos_data(FILE_PATH, memos)
  redirect '/memos'
end
