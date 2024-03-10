require 'gosu'
require_relative './cash_register.rb'

class Window < Gosu::Window
  def initialize
    super(640, 480, false)
    @cash_register = CashRegister.new(self) 
  end
  
  def needs_cursor?; true; end

  def button_down(id)
    super
    exit if id == Gosu::KB_ESCAPE

    @cash_register.button_down(id)
  end

  def update
    @cash_register.update
  end
  
  def draw
    @cash_register.draw
  end
end

Window.new.show