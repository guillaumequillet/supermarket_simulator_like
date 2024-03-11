# left clic will enable scanner
# space may take the product from right to center
# when scanned, space make take the product from center to left (customer)
# the product may need to be turned to display the bar code

class Product
  def initialize(x, y, type)
    generate_barcode
    @x, @y = x, y
  end

  def generate_barcode
    # relative to the product origin itself
    x, y, w, h = 0, 0, 32, 16
    @barcode = { x: x, y: y, w: w, h: h }
  end

  def update
  
  end

  def draw
  
  end
end

class ProductScan
  def initialize(window)
    @window = window
    @state = nil
    @keys = {
      scanning: Gosu::MS_LEFT
    }
  end

  def button_down(id)

  end

  def button_up(id)
    case @state
    when :scanning
      @state = nil if id == @keys[:scanning]
    end
  end

  def update(dt)
    if Gosu.button_down?(@keys[:scanning])
      @state = :scanning
    end
  end

  def draw_scanner
    x, y, w, h = @window.mouse_x, @window.mouse_y, 128, 32
    Gosu.draw_rect(x - w / 2, y - h / 2, w, h, Gosu::Color.new(128, 255, 0, 0))
  end

  def draw
    case @state
    when :scanning
      draw_scanner 
    end
  end
end