# left clic will enable scanner
# space may take the product from right to center
# when scanned, space make take the product from center to left (customer)
# the product may need to be turned to display the bar code

class Product
  def initialize(infos, x = 0, y = 0)
    @infos = infos
    @x, @y = x, y
    @box_color = Gosu::Color.new(255, *@infos['box_color'])
  end

  def is_scanned?(x, y, w, h)
    barcode_x, barcode_y, barcode_w, barcode_h = @infos['barcode']
    
    # scanner is drawn from the center (mouse_x, mouse_y)
    x = x - w / 2
    y = y - h / 2
    
    # we want to take all width but at least 1 pixel in height (1D barcode)
    if barcode_x + @x >= x && barcode_x + @x + barcode_w <= x + w && y >= barcode_y + @y && y <= barcode_y + barcode_h + @y
      return true
    end

    return false
  end

  def update
  
  end

  def draw
    box_width, box_height, box_length = @infos['size']
    barcode_x, barcode_y, barcode_w, barcode_h = @infos['barcode']

    Gosu.translate(@x, @y) do
      # - MAIN BOX
      # top
      Gosu.draw_rect(0, 0, box_width, box_length, Gosu::Color::BLACK) # stroke    
      Gosu.draw_rect(1, 1, box_width - 2, box_length - 2, @box_color)    
      
      # front
      Gosu.draw_rect(0, box_length, box_width, box_height, Gosu::Color::BLACK) # stroke    
      Gosu.draw_rect(1, box_length + 1, box_width - 2, box_height - 2, @box_color)  
      
      # - BARCODE
      Gosu.draw_rect(barcode_x, barcode_y, barcode_w, barcode_h, Gosu::Color::WHITE)
    end
  end
end

class ProductScan
  def initialize(window)
    @window = window
    @state = nil

    @sfx = {
      scan: Gosu::Sample.new('./sfx/beep-sound-8333.mp3')
    }

    @keys = {
      scanning: Gosu::MS_LEFT
    }
    @products = []
    @scanner_width, @scanner_height = 48, 32
    @scan_lock = false

    load_products_info
  end
  
  def load_products_info
    @products_info = JSON.parse(File.read('./data/products.json'))
  end

  def button_down(id)
    
  end

  def button_up(id)
    case @state
    when :scanning
      if id == @keys[:scanning]
        @state = nil
        @scan_lock = false
      end
    end
  end

  def spawn_products(qty = 1)
    # todo : set quantity somewhere else, related to game level etc.
    qty.times do 
      x = 100
      y = 50
      @products.push Product.new(@products_info.sample, x, y)
    end
  end

  def update(dt)
    if Gosu.button_down?(@keys[:scanning])
      @state = :scanning
    end

    case @state
    when :scanning
      # scanning is locked if a scan hit. The trigger must be released to scan again
      unless @scan_lock
        @products.each do |product|
          if product.is_scanned?(@window.mouse_x, @window.mouse_y, @scanner_width, @scanner_height)
            @sfx[:scan].play
            @scan_lock = true
            break
          end
        end
      end
    end
  end

  def draw_scanner
    # we mustn't draw the scanner if it's locked
    unless @scan_lock
      x, y, w, h = @window.mouse_x, @window.mouse_y, @scanner_width, @scanner_height
      Gosu.draw_rect(x - w / 2, y - h / 2, w, h, Gosu::Color.new(128, 255, 0, 0))
    end
  end

  def draw_products
    @products.each {|product| product.draw}
  end

  def draw
    Gosu.draw_rect(0, 0, @window.width, @window.height, Gosu::Color.new(255, 255, 0, 255))
    draw_products

    case @state
    when :scanning
      draw_scanner 
    end
  end
end