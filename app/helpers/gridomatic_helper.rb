# -*- encoding : utf-8 -*-
module GridomaticHelper
  COLORS = %w( blue red green yellow cyan orange purple )

  # Render multiple boxes.
  # Takes as argument a single array of Hash
  # For the Hash options, please see render_box.
  #
  # The boxes are wrapped in a div with class "textboxes".
  # You can pass individual styling using :textboxes_style => textboxes_style.
  #
  # You can specify a template Hash ( :template => template ) which will be merged with each
  # indivdual's box's options Hash. This way, you can create a list of boxes that look the same
  # but some have their own characteristics.
  # 
  # Also adds a div with style "clear: both" after the output so other objects won't start floating.
  # If you don't want that, add :noclear => true as an option.
  def render_boxes(array = [], options = {})
    boxes = ""

    template = {}

    if options[:template].class.to_s.eql?("Hash")
      template = options[:template]
    end

    array.each do |individual_options|
      box_options = template
      box_options = template.merge(individual_options) unless individual_options.nil?
      r = render_box(box_options)

      unless individual_options[:link].blank?
        r = "<a href='#{individual_options[:link]}' target='#{individual_options[:link_target]}' class='no_underline render_boxes'>#{r}</a>"
      end

      boxes += r unless r.blank?
    end

    boxes_div = content_tag :div, boxes, :class => "textboxes", :style => options[:textboxes_style]

    clear_both_ = ""

    unless options[:noclear] === true
      clear_both_ = clear_both
    end

    boxes_div + clear_both_
  end

  # Render a box.
  #
  # options:
  # - content (string)
  # - heading (string)
  # - float_left (true/false)
  # - text_align_center (true/false)
  # - highlight (true/false)
  # - background_image (url)
  # - bigfont (true/false)
  # - heading_color (color name, e.g. 'red')
  # - background_color (color name, e.g. 'blue')
  # - inner_div_style (css style, e.g. "width: 382px; height: 281px;")
  # - outer_div_style (same)
  # - heading_style (same)
  # - height (css style unit, e.g. "100px" or "6em")
  # - solid_background (true/false)
  #
  # You can wrap an <a> tag around the box and it will have a:hover CSS enabled, e.g.
  # - link_to "http://www.example.com/" do
  #  = render_box do
  #   - "bar"
  def render_box(options = {})
    # list of classes for the outer div.
    outer_div_classes = [ "textbox_container" ]
    # inner div, same story
    inner_div_classes = [ "textbox" ]
    # heading
    heading_classes = [ "heading" ]

    content = yield if block_given?
    content ||= options[:content]
    
    return nil if content.blank? && options[:heading].blank? unless options[:empty]

    # Options:
    # float_left
    outer_div_classes.push("float_left") if options[:float_left] === true
    # text_align_center
    inner_div_classes.push("text_align_center") if options[:text_align_center] === true
    # highlight
    inner_div_classes.push("highlight") if options[:highlight] === true
    # background_image
    background_image = options[:background_image]
    # header color
    heading_color = options[:heading_color]
    inner_div_classes.push("textbox_#{heading_color}") unless heading_color.blank?
    # background color
    background_color = options[:background_color]

    ############################################################################
    # inner div
    ############################################################################

    inner_div_classes.push("#{background_color}_background") unless background_color.blank?

    inner_div_options = { :class => c(inner_div_classes) }
    inner_div_styles = []
    unless background_image.blank?
      # opacity:0.4;filter:alpha(opacity=40);
      inner_div_styles.push "background: url(#{background_image}) no-repeat center;"
    end

    unless options[:height].blank?
      inner_div_styles.push "height: #{options[:height]}"
    end

    unless options[:width].blank?
      inner_div_styles.push "width: #{options[:width]}"
    end

    unless inner_div_styles.blank?
      inner_div_options[:style] = c(inner_div_styles)

    end
    inner_div_options[:style] ||= options[:inner_div_style] # can be overridden

    ############################################################################
    # outer div
    ############################################################################

    outer_div_options = { :class => c(outer_div_classes) }
    outer_div_options[:style] = options[:outer_div_style]

    ############################################################################
    # text div
    ############################################################################

    text_div_options = {}
    text_div_classes = []

    text_div_classes.push "bigfont" if options[:bigfont] === true
    text_div_classes.push "solid_background" if options[:solid_background] === true

    text_div_options[:class] = c(text_div_classes)

    ############################################################################
    # go render
    ############################################################################

    # let's go, outer div
    content_tag :div, outer_div_options do
      content_tag :div, inner_div_options do
        # heading
        heading = ""
        heading = content_tag :p, options[:heading], :class => c(heading_classes), :style => options[:heading_style] unless options[:heading].blank?
        # text div
        content_tag_ = content_tag :div, text_div_options do
          content_tag :p, content, :class => "inner_p"
        end
        # do it!
        heading + content_tag_
      end
    end
  end

  # If you want to put two boxes side by side, they both have to be float: left
  # Add this tag after the last one to prevent other blocks from floating.
  def clear_both
    content_tag :div, nil, :class => "clear_both"
  end

  private

  # c: convert array to string just like to_s but with a space between them.
  def c(array = [])
    str = ""

    for a in array
      str += a + " "
    end

    str.strip
  end
end

