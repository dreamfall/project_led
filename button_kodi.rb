require 'rubygems'
require 'bundler/setup'
require 'rpi_gpio'

class ButtonKodi
  BUTTON_PIN = 37

  def run
    setup
    first_time = true

    while true do
      sleep 0.05

      if RPi::GPIO.low? BUTTON_PIN
        puts "button down"
      end
    end
  ensure
    RPi::GPIO.clean_up
  end

  private

  def setup
    RPi::GPIO.set_numbering :board
    RPi::GPIO.setup LED_PIN, as: :output, initialize: :low
    RPi::GPIO.setup BUTTON_PIN, as: :input, pull: :up
  end
end

ButtonKodi.new.run
