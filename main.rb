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
    
  end

  get '/' do
    # TODO: Write the front end.
  end
  
  get '/:name_of_god_param/*' do
    
    bible_lookup_args = params[:splat][0].split('/')
    name_of_god = params[:name_of_god_param]
    
    # TODO: Handle bible_lookup_args == nil
    http_response = sub_god_in(
      name_of_god.gsub('-',' '), # URIs use hyphens for spaces
      @@bible.lookup(*bible_lookup_args) # TODO: Handle nil lookup (not found).
      )
      
    http_response.to_json
    
  end
  
  # TODO: Custom 404
  
  run!
  
end