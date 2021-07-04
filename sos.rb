#!/usr/bin/ruby

require 'rubygems'
require 'bundler/setup'
require 'rpi_gpio'

RPi::GPIO


class LEDBlinker
  LED_PIN = 11

  def run
    100.times do |i|
      blink(:long)
      blink(:long)
      blink(:long)

      blink(:short)
      blink(:short)
      blink(:short)

      blink(:long)
      blink(:long)
      blink(:long)
    end
  ensure
    RPi::GPIO.clean_up
  end

  private

  def blink(duration)
    case duration
    when :short
      RPi::GPIO.set_high LED_PIN
      sleep 0.3
      RPi::GPIO.set_low LED_PIN
      sleep 0.3
    when :long
      RPi::GPIO.set_high LED_PIN
      sleep 0.8
      RPi::GPIO.set_low LED_PIN
      sleep 0.3
    end
  end

  def setup
    RPi::GPIO.set_numbering :board
    RPi::GPIO.setup LED_PIN, as: :input, initialize: :low
  end
end

LEDBlinker.new.run
