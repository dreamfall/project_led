require 'rubygems'
require 'bundler/setup'
require 'rpi_gpio'


class ButtonBlink
  LED_PIN = 11
  BUTTON_PIN = 12

  def run
    setup

    while true do
      if RPi::GPIO.high? BUTTON_PIN
        RPi::GPIO.set_high LED_PIN
      else
        RPi::GPIO.set_low LED_PIN
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

ButtonBlink.new.run
