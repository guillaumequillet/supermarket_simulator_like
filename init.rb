require 'gosu'
require_relative './cash_register.rb'
require_relative './product_scan.rb'

class Window < Gosu::Window
  def initialize
    super(640, 480, false)
    @cash_register = CashRegister.new(self) 

    @state = :cash_register
  end
  
  def needs_cursor?; true; end

  def button_down(id)
    super
    exit if id == Gosu::KB_ESCAPE

    @cash_register.button_down(id)
  end

  def update
    @dt ||= Gosu::milliseconds
    @dt = Gosu::milliseconds - @dt
    
    case @state
    when :cash_register
      @cash_register.update(@dt)
    end
    
    @dt = Gosu::milliseconds
  end
  
  def draw
    case @state
    when :cash_register
      @cash_register.draw
    end
  end
end

Window.new.show