### Coiny
What's the main reason for Coiny for Coinbase Exchange? My Macbook Pro can't handle the web server platform. She starts acting sluggish and my fan turns on.

### Ruby Version

  ruby 2.1.0p0 (2013-12-25 revision 44422) [x86_64-darwin14.0]

### Prerequisites
	sudo gem install coinbase-exchange

Optional (if errors)

	sudo gem install eventmachine

	sudo apt-get install ruby-dev
	install build-essential g++

	sudo apt-get install libssl-dev
	install libsqlite3-dev
	
### Getting Started
1. Edit line 28 with your Coinbase Exchange API credentials.

### Add Features
1. YAML for API Keys?
2. Orderbook
3. Make some charts out of this data
4. Cancel ALL buy orders, or just sell orders

(•) Cancel ALL open orders, and certain order IDs (CAREFUL, NO REGEX FOR IDs)
(•) Separate Open orders
(•) Check market price before buying or selling
(•) Sell and Buy Protection = noob safty
(•) Switch statement has been rewriten for commands
(•) Losses and Winnings / Net worth