load('alfred_feedback.rb')

queries = ARGV

return if queries.empty?

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

all = `#{sqlite3} "#{db}" "SELECT ZFULL_NAME,ZHTML_URL,ZREPODESCRIPTION FROM ZOMSREPO"`.split(/\n/)

all.map! {|item| item.split('|', 4) }

feedback = Feedback.new

all.each do |fullname, url, desc|
  if queries.all? {|query| [fullname, desc].any? {|str| str.downcase.include?(query.downcase) } }
    feedback.add_item({:title => fullname, :subtitle => desc, :arg => url})
  end
end

puts feedback.to_xml
