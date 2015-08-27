require 'coinbase/exchange'
require 'eventmachine'

rest_api = Coinbase::Exchange::AsyncClient.new(api_key, api_secret, api_pass)
websocket = Coinbase::Exchange::Websocket.new(product_id: 'BTC-USD',
                                              keepalive: true)

# Getting Order Array for ID's
order_array = nil
rest_api.orders(status: 'open') do |resp|
	# Store the whole order Array
	order_array = resp
end

# Debug
#yourfile = "/home/matrixfox/coiny/debug.txt"

order = nil
# Websocket
spot_rate = nil
boolen = true;

websocket.match do |msg|
  spot_rate = msg.price
  
  if spot_rate <= 225 && boolen == true
    boolen = false
    # Debugging
    #File.open(yourfile, 'w') { |file| file.write("Spot Rate: $ %.2f" % spot_rate) }
    # Cancel Profit Orders
    for order in order_array do
        rest_api.cancel(order.id)
    end
  	# Bail Out
  	rest_api.ask(0.01, 300) do
  	  EM.stop
  	end
  end
end

# Health Monitor
EM.run do
  websocket.start!
  websocket_ping = Time.now
  
  EM::PeriodicTimer.new(1) do
  	# The Websocket missed 3 consecutive pings
    if Time.now - websocket_ping > 30
      # Debugging
      #File.open(yourfile, 'w') { |file| file.write("Websocket Pinged out") }
      # Cancel Profit Orders
      for order in order_array do
        rest_api.cancel(order.id)
      end
      # Sell-off
      rest_api.ask(0.01, 320) do
        EM.stop
      end
    end
  end
  
  EM::PeriodicTimer.new(10) do
    websocket.ping { websocket_ping = Time.now }
  end
end