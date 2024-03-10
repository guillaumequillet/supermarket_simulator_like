class CashRegister
  def initialize(window)
    @window = window

    @gfx = {
      tiroir: Gosu::Image.new('./gfx/cash_register.png', retro: true),
      coins: Gosu::Image.load_tiles('./gfx/euro_coins.png', 32, 32, retro: true),
      billets: Gosu::Image.load_tiles('./gfx/euro_billets.png', 64, 128, retro: true),
      counter: Gosu::Image.new('./gfx/counter.png', retro: true),
      counter_border: Gosu::Image.new('./gfx/counter_border.png', retro: true)
    } 

    @billet_offset = [6, 4]

    @areas = {
      billet_5:   [42, 20, 76, 136], 
      billet_10:  [122, 20, 76, 136], 
      billet_20:  [202, 20, 76, 136], 
      billet_50:  [282, 20, 76, 136], 
      billet_100: [362, 20, 76, 136], 
      billet_200: [442, 20, 76, 136], 
      billet_500: [522, 20, 76, 136], 
      coin_2e:    [42, 176, 66, 58], 
      coin_1e:    [112, 176, 66, 58], 
      coin_50:    [182, 176, 66, 58], 
      coin_20:    [252, 176, 66, 58], 
      coin_10:    [322, 176, 66, 58], 
      coin_5:     [392, 176, 66, 58], 
      coin_2:     [462, 176, 66, 58], 
      coin_1:     [532, 176, 66, 58]
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
    @hand_elements = []
    @hand_destination = {x: @window.width / 2, y: @window.height - 100}
    @hand_destination_coins = {x: @window.width / 2 - 100, y: @window.height - 100}

    options = {name: './gfx/rainyhearts.ttf', retro: true, bold: true}
    @font = Gosu::Font.new(30, options)
  end

  def button_down(id)
    pick_money if id == Gosu::MS_LEFT
    cancel_money if id == Gosu::MS_RIGHT
    p @hand_elements.inspect if id == Gosu::KB_SPACE
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
        element_to_delete = @hand_elements.find_index {|e| e[:type] == type}
        @hand_elements.delete_at(element_to_delete)
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

      destination = type.to_s.start_with?('coin') ? @hand_destination_coins : @hand_destination
      dest_x = destination[:x] + Gosu.random(-20, 20)
      dest_y = destination[:y] + Gosu.random(-20, 20)
      dest_angle = Gosu.random(-20, 20)

      hand_element = {
        type: type,
        position: {
          x: @areas[type][0] + @areas[type][2] / 2,
          y: @areas[type][1] + @areas[type][3] / 2,
          angle: 0
        },
        destination: {
          x: dest_x,
          y: dest_y,
          angle: dest_angle
        },
        in_place: false
      }
      @hand_elements.push hand_element
      @counters[type] += 1
      break
    end
  end

  def update_hand_elements
    @hand_elements.each do |hand_element|
      next if hand_element[:in_place]

      type = hand_element[:type]
      destination = hand_element[:destination]

      # we want to move the hand element to @hand_destination
      move_speed = 5.0
      if hand_element[:position][:x] < destination[:x]
        hand_element[:position][:x] += move_speed
        hand_element[:position][:x] = destination[:x] if hand_element[:position][:x] > destination[:x]
      elsif hand_element[:position][:x] > destination[:x]  
        hand_element[:position][:x] -= move_speed 
        hand_element[:position][:x] = destination[:x] if hand_element[:position][:x] < destination[:x]
      end

      if hand_element[:position][:y] < destination[:y]
        hand_element[:position][:y] += move_speed
        hand_element[:position][:y] = destination[:y] if hand_element[:position][:y] > destination[:y]
      elsif hand_element[:position][:y] > destination[:y]  
        hand_element[:position][:y] -= move_speed 
        hand_element[:position][:y] = destination[:y] if hand_element[:position][:y] < destination[:y]
      end

      rot_speed = 1.0
      if hand_element[:position][:angle] < destination[:angle]
        hand_element[:position][:angle] += rot_speed
        hand_element[:position][:angle] = destination[:angle] if hand_element[:position][:angle] > destination[:angle]
      elsif hand_element[:position][:angle] > destination[:angle]
        hand_element[:position][:angle] -= rot_speed
        hand_element[:position][:angle] = destination[:angle] if hand_element[:position][:angle] < destination[:angle]
      end

      # if it reached it, we set :in_place to true and add the money
      hand_element[:in_place] = (hand_element[:position][:x] == destination[:x]) && (hand_element[:position][:y] == destination[:y]) && (hand_element[:position][:angle] == destination[:angle])

      if hand_element[:in_place]
        @money += @values[type]
        @money = @money.round(2)
      end
    end
  end

  def update
    update_hand_elements
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

  def draw_hand_elements
    @hand_elements.each do |hand_element|
      type, x, y, angle = hand_element[:type], hand_element[:position][:x], hand_element[:position][:y], hand_element[:position][:angle]
      i = @areas.keys.index(type)

      if type.to_s.start_with?('billet')
        @gfx[:billets][i].draw_rot(x, y, 0, angle)
      elsif type.to_s.start_with?('coin')
        i = i - 7 # we want to count from first coin
        @gfx[:coins][i].draw_rot(x, y, 0, angle)
      end
    end
  end

  def draw
    render unless defined?(@render)
    @render.draw(0, 0, 0)
    @font.draw_text("Money : #@money", 10, 480 - @font.height - 10, 1)
    draw_counters
    draw_hand_elements
  end
end