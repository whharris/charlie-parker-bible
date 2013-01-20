require 'xmlsimple'

module ParamCleaner
  
  def clean(param)
    string = param.gsub('-',' ')
    string
  end
  
end

class Bible
  
  include ParamCleaner
  
  def initialize(bible_xml)   
    @data = XmlSimple.xml_in(bible_xml, 'KeyAttr' => 'name')
  end
  
  def find(*args)
    
    if args.count == 1
      @data['book'][clean(args[0])]
    
    elsif args.count == 2
      @data['book'][clean(args[0])]['chapter'][args[1]]
    
    elsif args.count == 3
      @data['book'][clean(args[0])]['chapter'][args[1]]['verse'][args[2]]
      
    end
    
  end
  
  # def book(bk)
  #   query = clean(bk)
  #   @data['book'][query]
  # end

end
