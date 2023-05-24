# frozen_string_literal: true

require 'sinatra'
require 'sinatra/contrib'
require 'sinatra/reloader'
require 'pg'
require 'cgi'
require 'bundler/setup'

def conn
  @conn ||= PG.connect(dbname: 'postgres')
end

configure do
  conn.exec('CREATE TABLE IF NOT EXISTS memos (id serial, title varchar(255), content text)')
end

def read_memos
  conn.exec('SELECT * FROM memos')
end

def read_memo(id)
  result = conn.exec_params('SELECT * FROM memos WHERE id = $1;', [id])
  result.first
end

def post_memos(memos)
  conn.exec_params('INSERT INTO memos(title, content) VALUES ($1, $2)', [memos['title'], memos['content']])
end

def edit_memos(memos)
  conn.exec_params('UPDATE memos SET title = $1, content = $2 WHERE id = $3;', [memos['title'], memos['content'], memos['id']])
end

def delete_memos(id)
  conn.exec_params('DELETE FROM memos WHERE id = $1;', [id])
end

get '/memos' do
  @memos = read_memos
  erb :top
end

get '/memos/new' do
  erb :new
end

get '/memos/:id' do
  @memo = read_memo(params[:id])
  erb :show
end

post '/memos' do
  memos = {
    'title' => params[:title],
    'content' => params[:content]
  }
  post_memos(memos)
  redirect '/memos'
end

get '/memos/:id/edit' do
  @memo = read_memo(params[:id])
  erb :edit
end

patch '/memos/:id' do
  memos = {
    'id' => params[:id],
    'title' => params[:title],
    'content' => params[:content]
  }
  edit_memos(memos)
  redirect '/memos'
end

delete '/memos/:id' do
  delete_memos(params[:id])
  redirect '/memos'
end
