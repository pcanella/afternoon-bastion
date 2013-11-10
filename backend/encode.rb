class Encode
  def initialize(key)
    @salt= key
  end

  def encrypt(text)
     Digest::SHA1.hexdigest("--#{@salt}--#{text}--")
  end
end

e= Encode.new("thisisasalt")

pas1= e.encrypt("christ")
#pas2= e.encrypt("This is my secret password")
#pas3= e.encrypt("This is NOT my secret password")

puts(pas1)
#puts(pas2)
#puts(pas2 == pas3)