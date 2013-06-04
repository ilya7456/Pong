#!/usr/bin/env ruby

require 'rubygems'
require 'gosu'

$player_1_controls = { "up" => Gosu::KbUp, "down" => Gosu::KbDown, "slow" => Gosu::KbRight, "fast" => Gosu::KbLeft }
$player_2_controls = { "up" => Gosu::KbW, "down" => Gosu::KbS, "fast" => Gosu::KbD, "slow" => Gosu::KbA }
$boundaries = [[10,590],[0,800],[0,0]]
$boundaries_paddle = [[670,740],[30,100]]
$paddle_vel_y = [0,0]
$hits = 0
$scores = { :player1 => 0, :player2 => 0 }

class Game <  Gosu::Window
    
    def initialize
        super 800, 600, false
        self.caption = "Pong"
        
        $window = self
        
        @font = Gosu::Font.new(self, Gosu::default_font_name, 20)
        
        @back = Gosu::Image.new($window, "img/back.png", false)
        
        @ball = Ball.new(150, 150, 2, 0, 0, "img/ball.png", 1, 40)
        
        @player1 = Player.new(740, 100, 0, 0, 0, "img/paddle.png", 1, 130)
        @player1.control_set($player_1_controls)
        @player1.identification = 0
        @player2 = Player.new(50, 100, 0, 0, 0, "img/paddle.png", 1, 130)
        @player2.control_set($player_2_controls)
        @player2.identification = 1

    end
    
    def draw
        @back.draw(0, 0, 0)
        @ball.draw
        @player1.draw
        @player2.draw
        
        @message = "Player 1: #{$scores[:player1]} | Player 2: #{$scores[:player2]} | Hits: #{$hits} "
        @font.draw(@message, \
                   10, 10, 5, 1.0, 1.0, 0xffffff00)
    end
    
    def update
        @ball.move
        @player1.move
        @player2.move
        
        $boundaries = [[10,590],[@player1.x,@player1.y],[@player2.x,@player2.y]]
        $paddle_vel_y = [@player1.vel_y,@player2.vel_y]
        
        $player_1_controls.each do |id, button|
            
            if button_down? button
                @player1.displace(id)
                $paddle_vel_y = [@player1.vel_y,@player2.vel_y]
            end
        end
        
        $player_2_controls.each do |id, button|
            
            if button_down? button
                @player2.displace(id)
                $paddle_vel_y = [@player1.vel_y,@player2.vel_y]
            end
        end
        
    end
end

class GameObject
    attr_accessor :x, :y, :vel_x, :vel_y, :angle, :path, :z_index, :size
    def initialize(x, y, vel_x, vel_y, angle, path, z_index, size)
        
        @x, @y, @vel_x, @vel_y, @angle, @path, @z_index, @size = x, y, vel_x, vel_y, angle, path, z_index, size
        
        @object = Gosu::Image.new($window, @path, false)
    end
    
    def draw
        @object.draw(@x,@y,@z_index)
    end
    
    def move
        @x += @vel_x
        @y += @vel_y
        
        collision
    end
end

class Ball < GameObject
    def collision
        
        if @x >= $boundaries[1][0] - @size && @x <= $boundaries[1][0] - @size + 6
            if @y >= $boundaries[1][1] - @size && @y <= $boundaries[1][1] + 130 + @size
                if $hits <= 20
                    @vel_x *= -1.05
                else
                    @vel_x *= -1
                end
                @vel_y += $paddle_vel_y[0] * 0.1
                $hits += 1
                @x = 739 - @size
                return
            end
        elsif @x - 10 <= $boundaries[2][0] && @x - 10 >= $boundaries[2][0] - 6
            if @y >= $boundaries[2][1] - @size && @y <= $boundaries[2][1] + 130 + @size
                if $hits <= 20
                    @vel_x *= -1.05
                else
                    @vel_x *= -1
                end
                @vel_y += $paddle_vel_y[1] * 0.1
                $hits += 1
                @x = 61
                return
            end
        end
        
        
        $boundaries[0].each_with_index do |y, i|
            if i == 0 and @y < y
                @vel_y *= -1
            elsif i == 1 and @y > y - @size
                @vel_y *= -1
            end
        end
        
        if @x <= 0
            @x = 400
            @y = 300
            @vel_x = @vel_y = 2
            $scores[:player1] += $hits
            $hits = 0
            sleep(1.5)
        elsif @x >= 800
            @x = 400
            @y = 300
            @vel_x = @vel_y = -2
            $scores[:player2] += $hits
            $hits = 0
            sleep(1.5)
        end
        
    end
    
end
    
    

class Player < GameObject
    attr_accessor :score, :lives, :thrust, :movable_v, :movable_h, :identification
    def control_set(hash)
        controls = hash
    end
    
    def collision
        
        if @y < 10
            @vel_y = 0
            @movable_v = "down"
        elsif @y > 590 - @size
            @vel_y = 0
            @movable_v = "up"
        else
            @movable_v = true
        end
        
        stop
    end
    
    def displace(id)
        if id == "up" and @movable_v != "down"
           @vel_y = -4.5
        elsif id == "down" and @movable_v != "up"
           @vel_y = 4.5
        end
    end
    
    def stop
        @vel_y = @vel_x = 0
    end
    
end

game = Game.new
game.show
