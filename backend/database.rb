require 'mongo'
require './Database'
include Mongo


#Database.new

class Database

  def initialize
    puts "TEST!"
  end

  def connect(dbName)
  	mongo_client = MongoClient.new("localhost", 27017).db(dbName)
    # Connect to database initially
    puts "Connected to database ahh!"
    return mongo_client
    #mongo_client.database_info.each { |info| puts info.inspect }
  end


def getAllLocations(clientdb)
	coll = clientdb.collection("locations")
	coll.find.each { |row| return row.inspect }
end


def getLocationsByCollegeId(clientdb, collegeId)
	coll = clientdb.collection("locations")
	coll.find("college_id" => collegeId)
	return 
end

  def test
  	return "THIS IS A TEST YP"
  end

end