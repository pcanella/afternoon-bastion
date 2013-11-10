require 'mongo'
require 'json'
require './Encode'

include Mongo


#Database.new

class Database
  attr_accessor :db
  attr_accessor :coll_locations
  attr_accessor :coll_users
  attr_accessor :encrypt

  def initialize(dbName)
  	mongo_client = MongoClient.new("localhost", 27017)
    self.db = mongo_client.db(dbName)
    self.coll_locations = self.db.collection("locations")
    self.coll_users = self.db.collection("users")
    self.encrypt = Encode.new("thisisasalt")
    # Connect to database initially
  end


  #This method gets all Locations, regardless of collegeID 
  def getAllLocations()
    coll = self.coll_locations
    puts coll.find()
    coll.find.each { |row| puts row.inspect }
  end

  # Gets Locations based upon collegeId field.
  def getLocationsByCollegeId(collegeId)
    coll = self.coll_locations
    p = coll.find("college_id" => collegeId).to_a
    col_array = JSON.generate(p)
    #puts col_array[0].to_s
    json_string = JSON.parse(col_array).to_s.gsub! "=>", ":"
    json_string.gsub! "nil", "null"
    loc = '{"Locations":' + test2 + '}'
    puts loc
    return loc

    #return p 
  end

  def storePass(_username, _password, _collegeid)
    e = self.encrypt
    pass = e.encrypt(_password)
    user = _username
    if checkUser(user) == true 
      doc = {"username" => user, "password" => pass, "college_id" => _collegeid}
      coll = self.coll_users 
      coll.insert(doc)
    else 
      puts "UH OH USER ALREADY TAKEN"
      return false
    end
  end

  # For checkPass, the _username should NOT be param data, but rather result from getUser
  def checkPass(_username, _password)
    e = self.encrypt
    encryptPass = e.encrypt(_password)
    #check a user's password
    coll = self.coll_users 
    combo = coll.find({"username" => _username, "password" => encryptPass}).to_a
    # if the user collection is empty here, it means the username is available
    test = JSON.generate(combo)
    test2 = JSON.parse(test)

    test2.each do |doc|
      if doc["password"].to_s === encryptPass.to_s
        return true 
      else
        return false
      end
    end
  end

  def checkUser(_username)
    coll = self.coll_users 
    user = coll.find("username" => _username).to_a
    # if the user collection is empty here, it means the username is available (returns true if empty?)
    return user.empty?
  end

  def getUser(_username)
    coll = self.coll_users 
    user = coll.find("username" => _username).to_a
    if user.empty?
      return nil
    else
      return _username
    end
  end

end