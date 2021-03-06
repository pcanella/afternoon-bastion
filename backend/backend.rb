require "sinatra/base"
require './Database'

class View < Sinatra::Base
  	enable :sessions

	attr_accessor :db_connect

	 def initialize
	    self.db_connect = Database.new("maps_db")
	  end

	get '/campusData' do
	  d = self.db_connect 
	  {'params' => params}
	  id = params[:college_id]
	  p = d.getLocationsByCollegeId(id.to_i)
	   #content_type 'application/json'
	  "<script type='text/javascript'> var t ='" + p + "';</script>"
	end

	get '/register' do
	  if session[:message] != nil
	   puts "SESSION DATA: " +  session[:username]
	  end
	  erb :form
	end

	post '/register' do
	  d = self.db_connect  
	  puts session[:username]
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
	  d = self.db_connect 
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
	  if LoggedIn?
	  "LOGGED IN YESSS"
	  end
	end

	get '/logout' do
		"You have successfully logged out"
		session.delete(:username) 
	end


	get '/protected' do
	 if LoggedIn?
	   "Welcome, authenticated client"
	  end
	end

	get '/createLocation' do
		d = self.db_connect 
		test = d.getCollegeIdOfUser(session[:username])
		erb :createLocation
	end

	post '/createLocation' do

	end



	helpers do
	  	
	  def LoggedIn?
	  # If user is logged in, they'll have correct session data
	  	if session[:username] != nil
	  	  return true
	  	else
	      redirect "/login"
	  	end
	  end	

	end

end