require 'xmlsimple'

class Bible

  def initialize(bible_xml) 
    # Expects an xml file with nodes like bible > book > chapter > verse.
    # Expects nodes to be named in the name attribute.
    # The second argument is necessary to create a hash using the name attr
    # as the key. Otherwise you get an array.
    @bible_full_text = XmlSimple.xml_in(bible_xml, 'KeyAttr' => 'name')
  end
  
  
  def lookup(*args)
    # The args array should look like this: [book, chapter, verse]
    # Chapter and verse are optional.
    # If bible_xml is formatted as expected, always returns a hash.
    
    # Book
    if args.count > 0
      book = @bible_full_text['book'][args[0].gsub('-',' ')] # URIs use hyphens for spaces
      return book if args.count == 1
    end
    # Book > Chapter
    if args.count > 1
      chapter = book['chapter'][args[1]] if args[1]
      return chapter if args.count == 2
    end
    # Book > Chapter > Verse
    if args.count > 2
      verse = chapter['verse'][args[2]] if args[2]
      return verse if args.count == 3
    end
    
  end

end