require 'sinatra'
require './Database'
  enable :sessions


get '/campusData' do
  d = Database.new("maps_db")
  {'params' => params}
  id = params[:college_id]
  p = d.getLocationsByCollegeId(id.to_i).to_s()
   content_type 'application/json'
  "#{p}"
end

get '/register' do
  if session[:message] != nil
   puts "SESSION DATA: " +  session[:message]
  end
  erb :form
end


post '/register' do
  d = Database.new("maps_db")
  # TODO: change 12345 to collegeid 
  puts session[:message]
  check = d.checkUser(params[:username])
  # Check if username is empty with checkUser, if true then name is available
  if (check == false)
  	"Sorry, this user already exists, please choose another name"
  else
  	d.storePass(params[:username], params[:password], 12345)
   "Successfully registered!"
   "<a href='/logout'>Log Out</a>"
  end
end

get '/login' do
	erb :form
end

post '/login' do
  d = Database.new("maps_db")
  user = d.getUser(params[:username])
  check = d.checkPass(user, params[:password])

  if(check == true)
  	session[:username] = user.to_s
  	puts session[:username]
  	redirect '/loggedin'
  else
  	puts "FAILED LOGIN ATTEMPT"
  	"You have put in the incorrect credentials"
  end
end

get '/loggedin' do
  "LOGGED IN YESSS"
end

get '/logout' do
	"You have successfully logged out"
	session.delete(:message) 
end


get '/protected' do
  if session[:message]
   "Welcome, authenticated client"
  else
  	"NOT ALLOWED HERE"
  end
end


helpers do
  def protected!
    return if authorized?
    headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
    halt 401, "Not authorized\n"
  end

  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? and @auth.basic? and @auth.credentials and @auth.credentials == ['admin', 'admin']
  end
end


