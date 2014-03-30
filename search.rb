load('alfred_feedback.rb')

queries = ARGV

return if queries.empty?

require 'open3'

db = "#{ENV['HOME']}/Library/Containers/com.iiiyu.ohmystar/Data/Library/Application Support/OhMyStar/OhMyStar.sqlite"

unless File.readable?(db)
  puts "Error: #{db} is not existed. Please install OhMyStar from App Store and try again"
  exit 0
end

sqlite3 = '/usr/bin/sqlite3'

unless File.executable?(sqlite3)
  puts "Error: #{sqlite3} not found"
  exit 0
end

related_fields = %w(ZFULL_NAME ZHTML_URL ZREPODESCRIPTION)
conditions = queries.map {|query|
  related_fields.map {|field|
    "#{field} like #{ "%#{query.gsub('%', '_')}%".inspect }"
  }.join(' OR ')
}.map {|query| "(#{query})" }.join(' AND ')

statement = "PRAGMA case_sensitive_like=OFF; SELECT ZFULL_NAME,ZHTML_URL,ZREPODESCRIPTION FROM ZOMSREPO WHERE #{conditions}"

feedback = Feedback.new
Open3.popen3(sqlite3, db, statement) do |stdin, stdout, stderr, thread|
  stdin.close

  until stdout.eof?
    fullname, url, desc = stdout.gets.split('|', 3)
    feedback.add_item({:title => fullname, :subtitle => desc, :arg => url})
  end
end
puts feedback.to_xml
