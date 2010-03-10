require File.expand_path("#{File.dirname(__FILE__)}/../../../spec_helper")

module Erector
  module Widgets
    module Externals
      describe JavascriptUsage do
        subject {JavascriptUsage.new :src=>"/dinner.js"}

        its(:to_s) {should == '<script src="/dinner.js" type="text/javascript"></script>'}

        it 'should equal one created with same options' do
          (subject == JavascriptUsage.new(:src=>"/dinner.js")).should == true
        end
        it 'should not equal one created with extra options' do
          (subject == JavascriptUsage.new(:src=>"/dinner.js", :options=>{:use_cdn=>true})).should == false
        end
        it 'should not equal one created with different path' do
          (subject == JavascriptUsage.new(:src=>"/lunch.js")).should == false
        end
        it 'should not equal StylesheetUsage with same file' do
          (subject == StylesheetUsage.new(:href=>"/dinner.js")).should == false
        end
      end

      describe StylesheetUsage do
        describe 'render with default options' do
          subject {StylesheetUsage.new :href=>"/css/tapatio.css"}
          its(:to_s) {should == '<link href="/css/tapatio.css" media="all" rel="stylesheet" type="text/css" />'}

          it 'should equal one created with same parameters' do
            (subject == StylesheetUsage.new(:href=>"/css/tapatio.css")).should == true
          end
          it 'should not equal one created with different name' do
            (subject == StylesheetUsage.new(:href=>"/css/salmon.css")).should == false
          end
          it 'should not equal one created with extra params' do
            (subject == StylesheetUsage.new(:href=>"/css/tapatio.css", :media=>'audio')).should == false
          end
        end

        describe 'render with media type' do
          subject {StylesheetUsage.new :href=>"/css/tapatio.css", :media => "print"}
          its(:to_s) {should == '<link href="/css/tapatio.css" media="print" rel="stylesheet" type="text/css" />'}
        end

      end
      describe JavascriptEmbed do

        context 'simple embed' do
          subject {JavascriptEmbed.new 'alert("works!");'}
          its(:to_s) {should == "<script type=\"text/javascript\">\n// <![CDATA[\nalert(\"works!\");\n// ]]>\n</script>\n"}
        end
        context 'simple embed of file' do
          subject {JavascriptEmbed.new :file=>"#{File.dirname(__FILE__)}/../../sample-file.txt"}
          its(:to_s) {should == "<script type=\"text/javascript\">\n// <![CDATA[\nsample file contents, 2 + 2 = \#{2 + 2}\n\n// ]]>\n</script>\n"}
        end
        context 'simple embed of file with interpolation' do
          subject {JavascriptEmbed.new :file=>"#{File.dirname(__FILE__)}/../../sample-file.txt", :interpolate=>true}
          its(:to_s) {should == "<script type=\"text/javascript\">\n// <![CDATA[\nsample file contents, 2 + 2 = 4\n\n// ]]>\n</script>\n"}
        end

        context 'interpolated embed' do
          Message='Hello there!'
          subject {JavascriptEmbed.new :body=>'alert("#{Message}");', :interpolate=>true}
          its(:to_s) {should == "<script type=\"text/javascript\">\n// <![CDATA[\nalert(\"Hello there!\");\n// ]]>\n</script>\n"}
        end

        context 'non-interpolated embed' do
          subject {JavascriptEmbed.new :body=>'alert("#{Message}");', :interpolate=>false}
          its(:to_s) {should == "<script type=\"text/javascript\">\n// <![CDATA[\nalert(\"\#{Message}\");\n// ]]>\n</script>\n"}
        end

      end

      describe StylesheetEmbed do
        context 'simple embed' do
          subject {StylesheetEmbed.new '.red { color: blue }'}
          its(:to_s) {should == '<style type="text/css">.red { color: blue }</style>'}
        end
        context 'interpolated embed' do
          RedColor = '#ff0000'
          subject {StylesheetEmbed.new '.red { color: #{RedColor} }', :interpolate=>true}
          its(:to_s) {should == '<style type="text/css">.red { color: #ff0000 }</style>'}
        end
        context 'non-interpolated embed' do
          subject {StylesheetEmbed.new '.red { color: #{RedColor} }', :interpolate=>false}
          its(:to_s) {should == '<style type="text/css">.red { color: #{RedColor} }</style>'}
        end
        context 'simple embed of file' do
          subject {StylesheetEmbed.new :file=>"#{File.dirname(__FILE__)}/../../sample-file.txt"}
          its(:to_s) {should == "<style type=\"text/css\">sample file contents, 2 + 2 = \#{2 + 2}\n</style>"}
        end
        context 'simple embed of file with interpolation' do
          subject {StylesheetEmbed.new :file=>"#{File.dirname(__FILE__)}/../../sample-file.txt", :interpolate=>true}
          its(:to_s) {should == "<style type=\"text/css\">sample file contents, 2 + 2 = 4\n</style>"}
        end
      end


#      describe Concatenator do
#        class DivWidget < Erector::Widget; def content div; end; end;
#        it 'should output a div' do
#          DivWidget.new.to_s.should == '<div />'
#        end
#        it 'should output nothing with no components to render' do
#          Concatenator.new(:widgets=>[]).to_s.should == ''
#        end
#        it 'should output its contents' do
#          Concatenator.new(:widgets=>[DivWidget, DivWidget]).to_a.should == '<div /><div />'
#        end
#      end
    end
  end
end
