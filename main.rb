require 'sinatra/base'
require 'json'

require './bible'

# Retrieved from here: http://code.google.com/p/sspc-website/source/browse/#svn%2Ftrunk%2Finclude%2Fbibles
BIBLE_DATA = 'kjv.xml'

class CharlieParkerBible < Sinatra::Base
  
  @@bible = Bible.new(BIBLE_DATA)
  
  helpers do
    
    def sub_god_in(name_sub, text_hash)
      # Traverses text_hash looking for value strings having the key 'content'.
      # If the string matches for "god" or "the lord", substitute with string name_sub.
      
      # TODO: Don't match 'the lord Jesus' eg 1 Corinthians 1:3.
      # TODO: Handle 'the LORD God' eg Genesis 2:4
      names_for_god = %r{god|the lord}i
      
      edited_text = {}
      edited_text.replace(text_hash)
      
      edited_text.each do |k,v|

        if k == 'content' && v.is_a?(String) && v.match(names_for_god)
          edited_text[k] = v.gsub(names_for_god, name_sub)
        end

        if v.is_a?(Hash)
          edited_text[k] = sub_god_in(name_sub,v)
        end

      end

    end
    
    def book_title_capitalize(book_title_str)
      # Books of the Bible should have all words capitalized except "or".
      capitalized_book_title = ""
      
      tmp = book_title_str.split(" ")
      tmp.each do |t|
        if t.match(%r{of}i)
          t.downcase!
        else
          t.capitalize! if t != "of"  
        end
        capitalized_book_title << t + " "
      end
      
      capitalized_book_title.strip
      
    end
    
  end

  get '/' do
    # TODO: Write the front end.
  end
  
  get '/:book_title' do
    # Don't return the whole Bible. It's over 5 mb.
    status 403
    "This file is too large. Try /#{params[:book_title]}/Genesis."
  end
  
  get '/*/' do
    # TODO: Deal with trailing slashes
  end
  
  get '/:name_of_god_param/*' do
    
    # Parse out params.
    bible_lookup_args = params[:splat][0].split('/') 
    name_of_god = params[:name_of_god_param]
    
    # Clean up params. URIs use hyphens for spaces.
    bible_lookup_args[0] = bible_lookup_args[0].gsub('-',' ') # Book name
    name_of_god = name_of_god.gsub('-',' ')
    bible_lookup_args[0] = book_title_capitalize(bible_lookup_args[0]) # Makes the book name param case insensitive.
    
    # Get the bible passage.
    bible_lookup_result = @@bible.lookup(*bible_lookup_args)
    
    if bible_lookup_result.nil?
      halt 404, "Passage not found."
    end
      
    if request.accept? 'application/json'
      http_response = sub_god_in(name_of_god, bible_lookup_result)
      http_response.to_json
    else
      status 406
      "JSON required."
    end

  end
  
  # TODO: Custom 404
  
  # run!
  
end