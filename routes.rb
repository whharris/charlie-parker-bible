bible = Bible.new('kjv.xml')

get '/' do
  bible.to_json
end

get '/:book' do |b|
  bible.find(b).to_json
  # bible.book(b).to_json
end

get '/:book/:chapter' do |b,c|
  bible.find(b,c).to_json
  # bible.book(b).chapter(c).to_json
end

get '/:book/:chapter/:verse' do |b,c,v|
  bible.find(b,c,v).to_json
  # bible.book(b).chapter(c).verse(v).to_json
end