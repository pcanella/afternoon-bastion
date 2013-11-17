require 'mongo'
require 'json'
require './Encode'

include Mongo
#Database.new

class String
  def numeric?
    Float(self) != nil rescue false
  end
end


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
    if p.empty? == false
      col_array = JSON.generate(p)
      #puts col_array[0].to_s
      json_string = JSON.parse(col_array).to_s.gsub! "=>", ":"
      #test2 = json_string.gsub! "nil", "null"
      loc = '{"Locations":' + json_string + '}'
    else
      loc = '{"Locations": null}'
    end
    return loc
  end

  # TODO: Add parameter sanitization
  def setLocation(params)
    coll = self.coll_locations
     newArray = {}
     params.each do |key, value|
       if value.to_s.numeric? === false
          if key != "action"
            newArray[key] = value
          end
      else
         #Check if Integer or floating point (for lat/long)
         if value.is_a?(Integer) === true 
         v = value.to_i
         #puts v.is_a?(Integer) 
         newArray[key] = v
       else
         f = value.to_f
         newArray[key] = f
       end
      end
     end
    puts params[:edit]
    verify = verifySlug(params[:slug])
    if params[:action] === "edit"
      # if we are in edit mode, find existing slug and update it (verifying the edit as well)
      #puts "VERIFY IS " + verify
      # if it verifies a slug (returning true), then UPDATE
      if verify === true
        #puts "VERIFY IS " + verify
        coll.update({"slug" => params[:slug]}, {"$set" => newArray})
      end
    else if params[:action] === "new"
      # if :action is new AND verify is false, then create a new item
      if verify === false 
        puts "Adding params to database...."
        coll.insert(newArray)
      else
        #next
        "Woah there! Looks like you are trying to create a new Location with an existing slug. Can't do that!"
        #if :edit is FALSE but verify is TRUE, then throw error to user (can't create a new item with the same slug) 
    end
      end
    end
  end


  def verifySlug(slugInQuestion)
    coll = self.coll_locations
     verify = coll.find("slug" => slugInQuestion).to_a
      # if there is anything in this array, then it must be true, since each location has a unique slug
      if verify.any? == true
        return true
      else
        return false
      end
  end


  def checkLastEnteredLocation(college_id)    
  #in mongoDB > db.locations.find({"college_id" : 12345}).sort({$natural:-1}).limit(1);
    coll = self.coll_locations
    c = coll.find({}, :sort => ['college_id', 1]).to_a
    return c
  end

  # We delete locations based on unique ID set by MongoDB
  def destroyLocation(params)
    coll = self.coll_locations
    coll.remove({"_id" => params[:_id]})
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

  def getCollegeId(_username)
    coll = self.coll_users
    college_id = coll.find({"username" => _username}, :fields => ["college_id"]).to_a
    #college_id.to_s

     college_id.each do |doc|
      return doc["college_id"].to_s
    end
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
