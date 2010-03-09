module Erector
  module Widgets
    module Externals
      class JavascriptUsage < Erector::Widget
        needs :src, :options=>{}

        def content
          script(:src => @src, :type=>'text/javascript')
        end

        def ==(other)
          (@src == other.instance_variable_get(:@src) &&
                  @options == other.instance_variable_get(:@options)) ? true : false
        end
      end

      class JavascriptEmbed < Erector::Widget
        needs :body

        def content
          script :type=>'text/javascript' do
            rawtext @body
          end
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
        def content
          style :type=>'text/css' do
            rawtext @body
          end
        end
      end

    end
  end
end

