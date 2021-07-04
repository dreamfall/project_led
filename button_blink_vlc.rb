require 'rubygems'
require 'bundler/setup'
require 'rpi_gpio'
require 'vlc-client'

class ButtonBlinkVlc
  LED_PIN = 11
  BUTTON_PIN = 12

  attr_reader :vlc

  def run
    setup
    first_time = true

    while true do
      next unless vlc.connected?

      if RPi::GPIO.low? BUTTON_PIN
        unless vlc.client.playing?
          if first_time
            vlc.play("/home/pi/Movies/rick.avi")
            first_time = false
          else
            vlc.play
          end
        end

        RPi::GPIO.set_high LED_PIN

      else
        if vlc.client.playing?
          vlc.pause
        end

        RPi::GPIO.set_low LED_PIN
      end
    end
  ensure
    vlc.server.stop
    RPi::GPIO.clean_up
  end

  private

  def setup
    @vlc = VLC::System.new
    RPi::GPIO.set_numbering :board
    RPi::GPIO.setup LED_PIN, as: :output, initialize: :low
    RPi::GPIO.setup BUTTON_PIN, as: :input, pull: :up
  end
end

ButtonBlinkVlc.new.run
