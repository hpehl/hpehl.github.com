# Title: Simple Image tag for Jekyll
# Authors: Brandon Mathis http://brandonmathis.com
#          Felix Schäfer, Frederic Hemberger
# Description: Easily output images with optional class names, width, height, title and alt attributes.
# The image is wrapped inside a <figure/> element. The class names are assigned to this element.
#
# Syntax {% img [class name(s)] [http[s]:/]/path/to/image [width [height]] [title text | "title text" ["alt text"]] %}
#
# Examples:
# {% img /images/ninja.png Ninja Attack! %}
# {% img left half http://site.com/images/ninja.png Ninja Attack! %}
# {% img left half http://site.com/images/ninja.png 150 150 "Ninja Attack!" "Ninja in attack posture" %}
#
# Output:
# <img src="/images/ninja.png">
# <img class="left half" src="http://site.com/images/ninja.png" title="Ninja Attack!" alt="Ninja Attack!">
# <img class="left half" src="http://site.com/images/ninja.png" width="150" height="150" title="Ninja Attack!" alt="Ninja in attack posture">
#

module Jekyll

  class ImageTag < Liquid::Tag
    @img = nil
    @fig = nil

    def initialize(tag_name, markup, tokens)
      fig_attributes = ['class']
      img_attributes = ['src', 'width', 'height', 'title']

      if markup =~ /(?<class>\S.*\s+)?(?<src>(?:https?:\/\/|\/|\S+\/)\S+)(?:\s+(?<width>\d+))?(?:\s+(?<height>\d+))?(?<title>\s+.+)?/i
        @fig = fig_attributes.reduce({}) { |fig, attr| fig[attr] = $~[attr].strip if $~[attr]; fig }
        @img = img_attributes.reduce({}) { |img, attr| img[attr] = $~[attr].strip if $~[attr]; img }
        if /(?:"|')(?<title>[^"']+)?(?:"|')\s+(?:"|')(?<alt>[^"']+)?(?:"|')/ =~ @img['title']
          @img['title']  = title
          @img['alt']    = alt
        else
          @img['alt']    = @img['title'].gsub!(/"/, '&#34;') if @img['title']
        end
        @fig['class'].gsub!(/"/, '') if @fig['class']
      end
      super
    end

    def render(context)
      if @fig && @img
        "<figure #{@fig.collect {|k,v| "#{k}=\"#{v}\"" if v}.join(" ")}><img #{@img.collect {|k,v| "#{k}=\"#{v}\"" if v}.join(" ")}></figure>"
      else
        "Error processing input, expected syntax: {% img [class name(s)] [http[s]:/]/path/to/image [width [height]] [title text | \"title text\" [\"alt text\"]] %}"
      end
    end
  end
end

Liquid::Template.register_tag('img', Jekyll::ImageTag)
