# http://recipes.sinatrarb.com/p/testing/minitest
ENV['RACK_ENV'] = 'test'
require './main.rb'
require 'minitest/autorun'
require 'rack/test'

include Rack::Test::Methods

def app
  CharlieParkerBible
end


## Main Features ##

describe "text replacement" do
  
  it "converts hyphens to spaces" do
    # Get args are path, query params, rack_env (in this case a header)
    get '/Charlie-Parker/Genesis/1/1', nil, 'HTTP_ACCEPT' => 'application/json'
    assert last_response.ok?
    assert_match "Charlie Parker", last_response.body
    refute_match "Charlie-Parker", last_response.body
  end
  
  it "replaces the word 'God' with the first URI parameter" do
    get '/Snoopy/Deuteronomy', nil, 'HTTP_ACCEPT' => 'application/json'
    assert last_response.ok?
    assert_match "Snoopy", last_response.body
    refute_match %r{god}i, last_response.body # Shouldn't show up lower case, but the regex is just in case
  end
  
  it "replaces the string 'the Lord' with the first URI parameter" do
    get '/Snoopy/Genesis/4', nil, 'HTTP_ACCEPT' => 'application/json'
    assert last_response.ok?
    assert_match 'I have gotten a man from Snoopy.', last_response.body
    refute_match 'I have gotten a man from the LORD.', last_response.body
  end

end

describe "book name capitalizer" do
  
  it "makes book name lookups case insensitive" do
    get '/Charlie-Parker/Genesis', nil, 'HTTP_ACCEPT' => 'application/json'
    lower_case_response_body = last_response.body
    get '/Charlie-Parker/genesis', nil, 'HTTP_ACCEPT' => 'application/json'
    assert last_response.ok?
    assert_equal lower_case_response_body, last_response.body
  end
  
  it "doesn't fail for book names containing the string 'of'" do
    get '/Charlie-Parker/song-OF-solomon', nil, 'HTTP_ACCEPT' => 'application/json'
    assert last_response.ok?
    get '/Charlie-Parker/sOnG-OF-sOlOmOn', nil, 'HTTP_ACCEPT' => 'application/json'
    assert last_response.ok?
  end
  
  it "doesn't fail for numbered books" do
    get '/Charlie-Parker/1-cORINTHIANS', nil, 'HTTP_ACCEPT' => 'application/json'
    assert last_response.ok?
  end
  
end


## Error Handlers ##

describe "full-text resource request error" do
  
  it "returns 403 for a full-text resource (eg /Charlie-Parker/)" do    
    get '/Charlie-Parker'
    assert_equal 403, last_response.status
  end
  
  it "returns a helpful message when denying access to full-text resources" do
    get '/Snoopy'
    assert_equal "This file is too large. Try /Snoopy/Genesis.", last_response.body 
  end
  
end

describe "error message responder for non-existent passages" do

  it "returns 404 for non-existent book names" do
    get '/Charlie-Parker/FakeBook'
    assert_equal 404, last_response.status
  end
  
  it "returns a helpful error message for non-existent book names" do
    get '/Charlie-Parker/asdf'
    assert_equal "Passage not found.", last_response.body
  end
  
  it "returns 404 for non-existent chapters" do
    get '/Charlie-Parker/Genesis/asdf'
    assert_equal 404, last_response.status
    get '/Charlie-Parker/asdf/asdf'
    assert_equal 404, last_response.status
  end
  
  it "returns a helpful error message for non-existent chapters" do
    get '/Charlie-Parker/Genesis/99999'
    assert_equal "Passage not found.", last_response.body
    get '/Charlie-Parker/9999/99999'
    assert_equal "Passage not found.", last_response.body
  end
  
  it "returns 404 for non-existent verses" do
    get '/Charlie-Parker/Genesis/1/asdf'
    assert_equal 404, last_response.status
    get '/Charlie-Parker/asdf/1/asdf'
    assert_equal 404, last_response.status
    get '/Charlie-Parker/asdf/asdf/asdf'
    assert_equal 404, last_response.status
  end
  
  it "returns a helpful error message for non-existent verses" do
    get '/Charlie-Parker/Genesis/1/asdf'
    assert_equal "Passage not found.", last_response.body
    get '/Charlie-Parker/asdf/1/asdf'
    assert_equal "Passage not found.", last_response.body
    get '/Charlie-Parker/asdf/asdf/asdf'
    assert_equal "Passage not found.", last_response.body
  end
  
end

describe "JSON required error" do
  
  it "returns 406 if the header doesn't accept json" do
    get '/Charlie-Parker/Genesis/1/1', nil, 'HTTP_ACCEPT' => 'text/html'
    assert_equal 406, last_response.status
  end
  
  it "returns a helpful error message if the header doesn't accept json" do
    get '/Charlie-Parker/1-Corinthians', nil, 'HTTP_ACCEPT' => 'text/html'
    assert_equal "JSON required.", last_response.body
  end
  
end

## Other ##

describe "trailing slashes handler" do
  it "does not return an error for URIs with a trailing slash" do
    get '/fakeurl/'
    assert_equal 200, last_response.status
    get '/some/fakeurl/'
    assert_equal 200, last_response.status
  end  
end


