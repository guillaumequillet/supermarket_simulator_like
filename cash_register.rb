class CashRegister
  def initialize(window)
    @window = window

    @gfx = {
      tiroir: Gosu::Image.new('./gfx/tiroir_caisse.png', retro: true),
      coins: Gosu::Image.load_tiles('./gfx/euro_coins.png', 32, 32, retro: true),
      billets: Gosu::Image.load_tiles('./gfx/euro_billets.png', 64, 128, retro: true),
      counter: Gosu::Image.new('./gfx/counter.png', retro: true),
      counter_border: Gosu::Image.new('./gfx/counter_border.png', retro: true)
    } 

    @billet_offset = [6, 4]

    @areas = {
      billet_5:   [42, 256, 76, 136], 
      billet_10:  [122, 256, 76, 136], 
      billet_20:  [202, 256, 76, 136], 
      billet_50:  [282, 256, 76, 136], 
      billet_100: [362, 256, 76, 136], 
      billet_200: [442, 256, 76, 136], 
      billet_500: [522, 256, 76, 136], 
      coin_2e:    [42, 412, 66, 58], 
      coin_1e:    [112, 412, 66, 58], 
      coin_50:    [182, 412, 66, 58], 
      coin_20:    [252, 412, 66, 58], 
      coin_10:    [322, 412, 66, 58], 
      coin_5:     [392, 412, 66, 58], 
      coin_2:     [462, 412, 66, 58], 
      coin_1:     [532, 412, 66, 58]
    }

    @values = {
      billet_5:   5, 
      billet_10:  10, 
      billet_20:  20, 
      billet_50:  50, 
      billet_100: 100, 
      billet_200: 200, 
      billet_500: 500, 
      coin_2e:    2, 
      coin_1e:    1, 
      coin_50:    0.5, 
      coin_20:    0.2, 
      coin_10:    0.1, 
      coin_5:     0.05, 
      coin_2:     0.02, 
      coin_1:     0.01
    }

    @counters = {
      billet_5:   0, 
      billet_10:  0, 
      billet_20:  0, 
      billet_50:  0, 
      billet_100: 0, 
      billet_200: 0, 
      billet_500: 0, 
      coin_2e:    0, 
      coin_1e:    0, 
      coin_50:    0, 
      coin_20:    0, 
      coin_10:    0, 
      coin_5:     0, 
      coin_2:     0, 
      coin_1:     0
    }

    @money = 0
    options = {name: './gfx/rainyhearts.ttf', retro: true, bold: true}
    @font = Gosu::Font.new(30, options)
  end

  def button_down(id)
    pick_money if id == Gosu::MS_LEFT
    cancel_money if id == Gosu::MS_RIGHT
  end

  def cancel_money
    x2, y2 = @window.mouse_x, @window.mouse_y

    @areas.each do |type, aabb|
      x, y, w, h = aabb
      next if x2 < x
      next if y2 < y
      next if x2 > x + w
      next if y2 > y + h
      if @counters[type] > 0
        @money -= @values[type]
        @money = @money.round(2)
        @counters[type] -= 1 
      end
      break
    end
  end

  def pick_money
    x2, y2 = @window.mouse_x, @window.mouse_y

    @areas.each do |type, aabb|
      x, y, w, h = aabb
      next if x2 < x
      next if y2 < y
      next if x2 > x + w
      next if y2 > y + h
      @money += @values[type]
      @money = @money.round(2)
      @counters[type] += 1
      break
    end
  end

  def update
  end

  def render
    @render = Gosu.render(@gfx[:tiroir].width, @gfx[:tiroir].height, retro: true) do
      # drawing of the cash register itself
      @gfx[:tiroir].draw(0, 0, 0)

      # billets drawing
      @areas.keys.each_with_index do |type, i|
        x, y, w, h = @areas[type]
        
        if type.to_s.start_with?('billet')
          x += @billet_offset[0]
          y += @billet_offset[1]
          @gfx[:billets][i].draw(x, y, 0)
        elsif type.to_s.start_with?('coin')
          # we want to draw a few coins of each time, with random position
          i = i - 7 # we want to count from first coin
          
          20.times do 
            max_x = w - @gfx[:coins][i].width
            max_y = h - @gfx[:coins][i].height
            offset_x = Gosu.random(0, max_x)
            offset_y = Gosu.random(0, max_y)
            @gfx[:coins][i].draw(x + offset_x, y + offset_y, 0)
          end
        end
      end
    end
  end

  def draw_counters
    @counters.each do |type, value|
      next if value == 0
      x, y, w, h = @areas[type]
      x += w / 2
      @gfx[:counter].draw_rot(x, y, 1, 0, 0.5, 0.5, 1, 1, Gosu::Color.new(128, 255, 255, 255))
      @gfx[:counter_border].draw_rot(x, y, 1, 0, 0.5, 0.5, 1, 1, Gosu::Color::BLACK)
      text_x = x - @font.text_width(value) / 2
      text_y = y - @font.height / 2

      # white stroke
      @font.draw_text(value, text_x - 1, text_y - 1, 1, 1, 1, Gosu::Color::WHITE)
      @font.draw_text(value, text_x + 1, text_y - 1, 1, 1, 1, Gosu::Color::WHITE)
      @font.draw_text(value, text_x - 1, text_y + 1, 1, 1, 1, Gosu::Color::WHITE)
      @font.draw_text(value, text_x + 1, text_y + 1, 1, 1, 1, Gosu::Color::WHITE)
      @font.draw_text(value, text_x, text_y + 1, 1, 1, 1, Gosu::Color::WHITE)
      @font.draw_text(value, text_x, text_y - 1, 1, 1, 1, Gosu::Color::WHITE)
      @font.draw_text(value, text_x - 1, text_y, 1, 1, 1, Gosu::Color::WHITE)
      @font.draw_text(value, text_x + 1, text_y, 1, 1, 1, Gosu::Color::WHITE)
      
      # actual text
      @font.draw_text(value, text_x, text_y, 1, 1, 1, Gosu::Color::BLACK)
    end
  end

  def draw
    render unless defined?(@render)
    @render.draw(0, 0, 0)
    @font.draw_text("Money : #@money", 10, 10, 1)
    draw_counters
  end
end