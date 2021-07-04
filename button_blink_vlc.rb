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
      sleep 0.05

      if RPi::GPIO.low? BUTTON_PIN
        puts "button down"
        if vlc_status != "playing"
          if first_time
            puts "First time play"

            vlc.play("/home/pi/Movies/rick.avi")
            first_time = false
          else

            puts "resume"
            vlc.play
          end
        end

        RPi::GPIO.set_high LED_PIN

      else
        puts "button up"

        if vlc_status == "playing"
          puts "vlc pause"

          vlc.client.pause
        end

        RPi::GPIO.set_low LED_PIN
      end
    end
  ensure
    puts "vlc stop"
    vlc.server.stop
    RPi::GPIO.clean_up
  end

  private

  def vlc_status
    if vlc.client.playing?
      vlc.client.status[:state]
    else
      "stopped"
    end
  end

  def setup
    @vlc = VLC::System.new
    RPi::GPIO.set_numbering :board
    RPi::GPIO.setup LED_PIN, as: :output, initialize: :low
    RPi::GPIO.setup BUTTON_PIN, as: :input, pull: :up
  end
end

ButtonBlinkVlc.new.run
