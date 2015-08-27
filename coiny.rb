require 'coinbase/exchange'

$help =  "Commands are:
  d: Dashboard
  o: Orders
  p: Price
  b: Buy
  s: Sell
  c: Cancel Orders
  q: quit\n"

class Coiny

  def initialize
    @coiny = {}
    @usd_currency = nil
    @usd_balance = nil
    @usd_available = nil
    @usd_hold = nil
    @btc_currency = nil
    @btc_balance = nil
    @btc_available = nil
    @btc_hold = nil
    @test = nil
    @depoisted = nil
  end

  def call_api()
	return Coinbase::Exchange::Client.new(api_key, api_secret, api_pass)
  end

  def get_accounts()
	money = Array.new
	call_api.accounts do |account|
	  # 1. What about - Widthdraws?
	  # 2. Bitcoin Depoists?
	  call_api.account_history(account.first.id) do |usdAccount|
		for entry in usdAccount do
		  if entry.details['transfer_type'] != nil
			money << BigDecimal(entry.amount)
		  end
		end
		@depoisted = money.inject(:+)
	  end
	  
	  account.each do |accounts|
		if accounts.currency == "USD"
		  @usd_currency = accounts.currency
		  @usd_balance = accounts.balance
		  @usd_available = accounts.available
		  @usd_hold = accounts.hold
		elsif accounts.currency == "BTC"
		  @btc_currency = accounts.currency
		  @btc_balance = accounts.balance
		  @btc_available = accounts.available
		  @btc_hold = accounts.hold
		end
	  end
	end
  end

  def last_price()
	call_api.last_trade do |resp|
	  return BigDecimal(resp['price'])
	end
  end

  def cmd_d(not_used)
	get_accounts()
	system "clear"
	
	# Check if you have BTC
	if @btc_balance != 0.0
	 worthMathtwo = @btc_balance * last_price
	end
	
	# USD
	p "=========="+@usd_currency+"=========="
	if worthMathtwo != nil
	  @test = @usd_balance + worthMathtwo
	  p "Talance    $ %f" % @test
	  p "Available  $ %f" % @usd_available
	  p "Held       $ %f" % @usd_hold
	  # USD Math
	  if @test != nil
	   worthMath = @test - @depoisted
	   if worthMath > 0
		 net = worthMathtwo + worthMath
		 p "Profits    $ %f" % worthMath
		 p "Net        $ %f" % net
	   else
		 net = worthMath + worthMathtwo
		 p "Losses     $ %f" % worthMath
		 p "Net        $ %f" % net
	   end
	  end
	else
	  # Default Balance - With no BTC
	  worthMath = @usd_balance - @depoisted
	  p "Balance    $ %f" % @usd_balance
	  p "Available  $ %f" % @usd_available
	  p "Held       $ %f" % @usd_hold
	  p "Frofits    $ %f" % worthMath
	end
	 # BTC - Start
	 p "=========="+@btc_currency+"=========="
	 p "Balance    ฿ %f" % @btc_balance
	 p "Available  ฿ %f" % @btc_available
	 p "Held       ฿ %f" % @btc_hold
	 # BTC Math
	 if worthMathtwo != nil
	  p "Worth      $ %f" % worthMathtwo
	 end
  end

  def cmd_p(not_used)
	p "======================="
	p "Last Price  : $ %.2f" % last_price()
	call_api.daily_stats do |daily|
		p "24h Highest : $ %.2f" % daily.high
		p "24h Lowest  : $ %.2f" % daily.low
	end
  end

  #
  # Account Orders *REWRITE ME*
  #
  def cmd_o(not_used)
	call_api().orders() do |resp|
	  resp.each do |order|
		if order.done_reason != 'canceled'
		  if order.type == "market"
			# market orders
			if order == order.funds
				p sprintf "Size : ฿ %f - #{order.type} Fee: $ %f - #{order.side}", order.size,order.fill_fees
			end
		  else
			if order.funds['settled'] == false
			  # Active Orders
			  p order.id
			  p sprintf "Size : ฿ %f - Price: $ %f - Fee: $ %f - #{order.side}", order.size, order.price, order.fill_fees
			  p '-----'
			else
			# just limit orders
			p sprintf "Size : ฿ %f - Price: $ %f - Fee: $ %f - #{order.side}", order.size, order.price, order.fill_fees
			end
		  end
		end
	  end
	end
  end

  def cmd_b(not_used)
	print "Buying BTC: "
	volume = gets
	
	compair_price = last_price
	market_price = compair_price + 5

	print "Market Price %.2f (Lowest Price Possible): " % compair_price
	order = gets

	  if BigDecimal(order) > market_price
		p 'order too high'
	  else
		call_api.bid("%.8f" % volume, "%.2f" % order)
	  end
  end

  def cmd_s(not_used)
	print "Selling BTC: "
	volume = gets
  
	compair_price = last_price
	market_price = compair_price - 5

	print "Market Price %.2f (Highest Price Possible): " % compair_price
	order = gets

	  if BigDecimal(order) < market_price
		p 'order too low'
	  else
		call_api.ask("%.8f" % volume, "%.2f" % order)
	  end
  end

  def cmd_c(arg)
	if arg == ""
	  call_api.orders(status: 'open') do |resp|
		# For Loop Canceling ALL Orders
		for order in resp do
		  call_api.cancel(order.id) do
			p "Order canceled successfully"
		  end
		end
	  end
	else
	  # Cancel Said Order
	  call_api.cancel(arg) do
		p "Order canceled successfully"
	  end
	end
  end

  def cmd_help(arg)
    print $help
    return ""
  end
end

obj = Coiny.new

cmd_re = /^\s*(\w+)\s*(.*)$/
print $help
while true
  print "Enter a command: "
  $stdout.flush

  cmdline = gets().chomp
  if cmd_re.match(cmdline)
    cmd = "cmd_" + $1
    args = $2
    if obj.respond_to?(cmd)
      begin
        obj.send(cmd, args)
        p "======================="
      rescue => msg
        print "Error: #{msg}\n"
      end
    elsif cmd == 'cmd_quit' || cmd == 'cmd_exit' || cmd == 'cmd_q'
      break
    else
      print "Error: #{cmd} not a recognized command\n"
    end
  else
    print "Can't deal with input [#{cmdline}] (type 'help' for more help, or 'q' to quit)\n"
  end
end