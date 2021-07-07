require 'rubygems'
require 'bundler/setup'
require 'rpi_gpio'

class TempHumidity
  DHTPin = 11

  class DHT
	  DHTLIB_OK             = 0
	  DHTLIB_ERROR_CHECKSUM = -1
	  DHTLIB_ERROR_TIMEOUT  = -2
	  DHTLIB_INVALID_VALUE  = -999

	  DHTLIB_DHT11_WAKEUP   = 0.020  #20ms
	  DHTLIB_TIMEOUT        = 0.0001 #100us

    attr_reader :humidity, :temperature, :pin
    attr_accessor :pin, :bits

    def initialize(pin)
      @humidity = 0
      @temperature = 0
      @pin = pin
		  self.bits = [0,0,0,0,0]
		  RPi::GPIO.set_numbering :board
    end


	  def read_sensor(wakeup_delay)
		  mask = 0x80
		  idx = 0
		  self.bits = [0,0,0,0,0]

		  # Clear sda
      RPi::GPIO.setup pin, as: :output, initialize: :high

		  sleep 0.5

		  # start signal
      RPi::GPIO.set_low pin
		  sleep(DHTLIB_DHT11_WAKEUP)
		  RPi::GPIO.set_high pin
		  # time.sleep(0.000001)
      RPi::GPIO.setup pin, as: :input

		  # Waiting echo
		  t = Time.current

		  while true
			  if RPi::GPIO.low?(pin)
				  break
        end
			  if dht_timeout?(t)
				  return DHTLIB_ERROR_TIMEOUT
        end
      end

		  # Waiting echo low level end
		  t = Time.current

 		  while RPi::GPIO.low?(pin)
			  if dht_timeout?(t)
				  return DHTLIB_ERROR_TIMEOUT
        end
      end

		  # Waiting echo high level end
		  t = Time.current

 		  while RPi::GPIO.high?(pin)
			  if dht_timeout?(t)
				  return DHTLIB_ERROR_TIMEOUT
        end
      end

		  40.times do
		    t = Time.current

			  while RPi::GPIO.low?(pin)
				  if dht_timeout?(t)
					  #print ("Data Low %d"%(i))
					  return DHTLIB_ERROR_TIMEOUT
          end
        end

			  t = Time.current

			  while RPi::GPIO.high?(pin)
				  if dht_timeout?(t)
					  #print ("Data HIGH %d"%(i))
					  return DHTLIB_ERROR_TIMEOUT
          end
        end

			  if (Time.current - t) > 0.00005
				  self.bits[idx] |= mask
        end

			  mask >>= 1

			  if mask == 0
				  mask = 0x80
				  idx += 1
        end
      end


		  # time.sleep(0.000001)

      RPi::GPIO.setup pin, as: :output, initialize: :high

      return DHTLIB_OK
    end

	  #Read DHT sensor, analyze the data of temperature and humidity
	  def read_dht11_once
		  rv = read_sensor
		  if rv != DHTLIB_OK
			  @humidity = DHTLIB_INVALID_VALUE
			  @temperature = DHTLIB_INVALID_VALUE
			  return rv
      end

		  @humidity = bits[0]
		  @temperature = bits[2] + bits[3]*0.1
		  sumcheck = (bits[0] + bits[1] + bits[2] + bits[3]) & 0xFF

		  if bits[4] != sumcheck
			  return DHTLIB_ERROR_CHECKSUM
      end

		  return DHTLIB_OK
    end

	  def read_dht11
		  result = DHTLIB_INVALID_VALUE

		  15.times do
			  result = read_dht11_once

			  if result == DHTLIB_OK
				  return DHTLIB_OK
        end

			  sleep 0.1
      end

		  return result
    end
  end

  def run
    dht = DHT.new(DHTPin)

    while true
      dht.read_dht11

      puts "Temperature: #{temperature}"
      puts "Humidity #{humidity}"

      sleep 60
    end
  ensure
    RPi::GPIO.clean_up
  end

  private

  def dht_timeout?(t)
    (Time.current - t) > DHTLIB_TIMEOUT
  end
end

TempHumidity.new.run
