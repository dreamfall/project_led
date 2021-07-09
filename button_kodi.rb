require 'rubygems'
require 'bundler/setup'
require 'rpi_gpio'

class ButtonKodi
  BUTTON_PIN = 37

  def run
    setup
    first_time = true

    wait_while_it_launches_sec = 10
    i = 0
    step = 0.05
    starting = false

    while true do
      sleep step

      if RPi::GPIO.low? BUTTON_PIN
        # is codi runing?
        if !starting && `ps -aux | grep kodi`.split("\n").count == 2
          pid = spawn "kodi-standalone"
          Process.detach(pid)
          starting = true
        else
          if starting
            if wait_while_it_launches_sec > i * step
              starting = false
            end

            i += 1
          end
        end
      end
    end
  ensure
    RPi::GPIO.clean_up
  end

  private

  def setup
    RPi::GPIO.set_numbering :board
    RPi::GPIO.setup BUTTON_PIN, as: :input, pull: :up
  end
end

ButtonKodi.new.run
