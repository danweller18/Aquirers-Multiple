class StaticPagesController < ApplicationController
  def home
  end

  def stocks
    require 'open-uri'
    require 'net/ftp'

    # Login to the FTP server
    ftp = Net::FTP.new('ftp.nasdaqtrader.com')
    ftp.login('anonymous', '')

    # Switch to the desired directory
    ftp.chdir('SymbolDirectory')

    # Get the file we need and save it to our 'ftp_tickers' directory
    ftp.getbinaryfile('nasdaqtraded.txt', 'ftp_tickers/nasdaqtraded.txt')

    #declare arrays
    lines = []
    nsymbol = []
    sname = []
    etf = []
    testv = []
    financials = []
    alist = []
    filename = "ftp_tickers/nasdaqtraded.txt"
    #open file read line by line
    File.open(filename) do |f|
      f.each_line do |line|
        #push line into array
        j = line
        lines.push(j)
        #collect symbols from line
        nsymbol << line.split('|')[1, 1].map(&:lstrip)
        #collect security name from line
        sname << line.split('|')[2, 1].map(&:lstrip)
        #collect etf value from line
        etf << line.split('|')[5, 1].map(&:lstrip)
        #collect test or not value from line
        if line.split('|')[7, 1] != nil
          testv << line.split('|')[7, 1].map(&:lstrip)
        end
        #collect Financial Status
        if line.split('|')[8, 1] != nil
          financials << line.split('|')[8, 1].map(&:lstrip)
        end
      end
      #itterate through etf
      #etf.each do |x|
        #delete etf value if it is ETF
      #  x.delete('Y')
      #end

      alist.push(nsymbol, sname, etf, testv, financials)

      #etf.each do |x|
      #  if x == 'Y'

      #end

      #pass variables to html.erb
      @Nasdaq = lines
      @nsymbol = nsymbol
      @sname = sname
      @etf = etf
      @testv = testv
      @financials = financials
      @alist = alist
    end #end of File open

    #pull json from yahoo finance and parse
    url = 'https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20yahoo.finance.quote%20where%20symbol%20in%20(%22YHOO%22%2C%22AAPL%22%2C%22GOOG%22%2C%22MSFT%22)&format=json&diagnostics=true&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys'
    file = open(url).read
    data = JSON.parse(file)
    #put results into arrays
    array1 = data['query']['results']
    array2 = array1['quote']

    #create symbol array and push symbols into it
    symbol = []
    for i in 0..3
      j = array2[i]['symbol'];
      symbol.push(j)
    end
    #Global variable holds symbol array
    @Symbols = symbol

    #create price array and push prices into it
    price = []
    for i in 0..3
      j = array2[i]['LastTradePriceOnly'];
      price.push(j)
    end
    #Global variable holds prices array
    @Prices = price
    #data = JSON.parse file.read

    # Construct the URL we'll be calling
#    request_uri = 'https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20yahoo.finance.quote%20where%20symbol%20in%20(%22YHOO%22%2C%22AAPL%22%2C%22GOOG%22%2C%22MSFT%22)&format=json&diagnostics=true&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys'
    #url = "{request_uri}"

    # Actually fetch the contents of the remote URL as a String.
    #buffer = open(url).read

    # Sample JSON response from fake API endpoint (a simple app running on my machine), but you can easily build it. Credit goes to Michael Hartl for the stellar "Build Twitter in Rails" tutorial:
    #
    # http://ruby.railstutorial.org/ruby-on-rails-tutorial-book
    #
    # Output after running it through http://jsonviewer.net to make it more readable.
    # ['0'] (
    # |    id =  2
    # |    name =  "Example User"
    # |    email =  "example@railstutorial.org"
    # |    created_at =  "2013-12-11T06:09:06.866Z"
    # |    updated_at =  "2013-12-11T06:09:06.866Z"
    #      # ... and more
    # |    )
    # ['1'] (
    # |    id =  4
    # |    name =  "Example User 2"
    # |    email =  "example@railstutorial.org"
    # |    created_at =  "2013-12-11T06:09:06.866Z"
    # |    updated_at =  "2013-12-11T06:09:06.866Z"
    #      # ... and more
    # |    )

    # Convert the String response into a plain old Ruby array. It is faster and saves you time compared to the standard Ruby libraries too.
    #result = JSON.parse(buffer)
    # An example of how to take a random sample of elements from an array. Pass the number of elements you want into .sample() method. It's probably a better idea for the server to limit the results before sending, but you can use basic Ruby skills to trim & modify the data however you'd like.
    #result = result.sample(5)

    # Loop through each of the elements in the 'result' Array & print some of their attributes.
    #result.each do |user|
    #  puts "#{user['id']}\t#{user['name']}\t#{user['email']}"
    #  puts "Registered: #{user['created_at']}\n\n"
    #end

    #data.each do |quote|
    #  puts "#{user['id']}\t#{user['name']}\t#{user['email']}"
    #  puts "Registered: #{user['created_at']}\n\n"
    #end


    # Expected output in this format:
    # Uncomment the next line to output the data inside the 5 elements returned from the JSON call. Google 'Ruby pp gem'.

    # pp result

    # 14  Kari Lynch  example-12@railstutorial.org
    # Registered: 2013-12-11T06:09:08.231Z

    # 20  Dr. Josh Bergstrom  example-18@railstutorial.org
    # Registered: 2013-12-11T06:09:08.788Z

    # 24  Haley Walter  example-22@railstutorial.org
    # Registered: 2013-12-11T06:09:09.157Z

    # 17  Ozella Barton example-15@railstutorial.org
    # Registered: 2013-12-11T06:09:08.511Z

    # 13  Mandy Reynolds  example-11@railstutorial.org
    # Registered: 2013-12-11T06:09:08.138Z

    puts "Finished!\n\n"
  end

  def about
  end
end
