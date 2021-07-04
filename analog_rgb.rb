require 'rubygems'
require 'bundler/setup'
require 'rpi_gpio'


class RgbLEDBlinker
  R_PIN = 11
  G_PIN = 13
  B_PIN = 15

  def run
    setup

    100.times do |i|
      blink(:red, :short)
      blink(:green, :short)
      blink(:blue, :short)

      blink(:red, :long)
      blink(:green, :long)
      blink(:blue, :long)

      blink(:red, :short)
      blink(:green, :short)
      blink(:blue, :short)

      sleep 0.8
    end
  ensure
    RPi::GPIO.clean_up
  end

  private

  def blink(color, duration)
    pin = pin_from_color(color)

    case duration
    when :short
      RPi::GPIO.set_high pin
      sleep 0.3
      RPi::GPIO.set_low pin
      sleep 0.3
    when :long
      RPi::GPIO.set_high pin
      sleep 0.8
      RPi::GPIO.set_low pin
      sleep 0.3
    end
  end

  def pin_from_color(color)
    case color
    when :red
      R_PIN
    when :green
      G_PIN
    when :blue
      B_PIN
    end
  end

  def setup
    RPi::GPIO.set_numbering :board
    RPi::GPIO.setup R_PIN, as: :output, initialize: :low
    RPi::GPIO.setup G_PIN, as: :output, initialize: :low
    RPi::GPIO.setup B_PIN, as: :output, initialize: :low
  end
end

RgbLEDBlinker.new.run
