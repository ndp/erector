module Erector
  module Widgets
    module Externals
      class JavascriptUsage < Erector::Widget
        needs :src, :options=>{}

        def content
          script(:src => @src, :type=>'text/javascript') #,  'xml:space'=>'preserve'
        end

        def ==(other)
          (@src == other.instance_variable_get(:@src) &&
              @options == other.instance_variable_get(:@options)) ? true : false
        end
      end

      class JavascriptEmbed < Erector::Widget
        needs :body

        def initialize(options={})
          body = Hash === options ? options.delete(:body) : options
          body = File.new(options.delete(:file)).read if options[:file]
          body = eval("<<INTERPOLATE\n" + body + "\nINTERPOLATE").chomp if options[:interpolate]
          super :body=>body
        end

        def content
          javascript @body
        end
      end

      class StylesheetUsage < Erector::Widget
        needs :href, :media=>'all', :options=>{}

        def content
          link({:rel => "stylesheet", :href => @href, :type => "text/css", :media => @media}.merge(@options))
        end

        def ==(other)
          @href == other.instance_variable_get(:@href) && @media == other.instance_variable_get(:@media) ? true : false
        end

      end


      class StylesheetEmbed < Erector::Widget
        needs :body

        def initialize(*args)
          options = Hash === args.last ? args.last : {}
          body = args.size > 0 ? args.shift : options.delete(:body)
          body = File.new(options.delete(:file)).read if options[:file]
          body = eval("<<INTERPOLATE\n" + body + "\nINTERPOLATE").chomp if options[:interpolate]
          super :body=>body
        end

        def content
          style :type=>'text/css' do
            rawtext @body
          end
        end
      end

#      class Concatenator < Erector::Widget
#        needs :widgets
#        def render
#          @widgets.each {|w| widget w }
#        end
#      end
    end
  end
end

