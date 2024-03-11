require 'gosu'
require_relative './cash_register.rb'
require_relative './product_scan.rb'

class Window < Gosu::Window
  def initialize
    super(640, 480, false)
    @cash_register = CashRegister.new(self) 
    @product_scan = ProductScan.new(self) 

    @state = :product_scan
  end
  
  def needs_cursor?; true; end

  def button_down(id)
    super
    exit if id == Gosu::KB_ESCAPE
    
    case @state
    when :cash_register
      @cash_register.button_down(id)
    when :product_scan
      @product_scan.button_down(id)
    end
  end

  def button_up(id)
    case @state
    when :cash_register
      @cash_register.button_up(id)
    when :product_scan
      @product_scan.button_up(id)
    end
  end

  def update
    @dt ||= Gosu::milliseconds
    @dt = Gosu::milliseconds - @dt
    
    case @state
    when :cash_register
      @cash_register.update(@dt)
    when :product_scan
      @product_scan.update(@dt)
    end
    
    @dt = Gosu::milliseconds
  end
  
  def draw
    case @state
    when :cash_register
      @cash_register.draw
    when :product_scan
      @product_scan.draw
    end
  end
end

Window.new.show