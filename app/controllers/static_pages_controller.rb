class StaticPagesController < ApplicationController
  def home
  end

  def stocks
    require 'cgi'
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
    symb = []
    names = []
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

      #make everything flat
      nsymbol.flatten!
      sname.flatten!
      etf.flatten!
      testv.flatten!
      financials.flatten!

      #create one array with all other arrays
      alist.push(nsymbol, sname, etf, testv, financials)

      #read through arrays
      (0...nsymbol.length).each do |i|
        (0...alist.length).each do |j|
          #delete ETf at alist[2][i] + Test Value at alist[3][i] + Pref stock at alist[0][i]
          if alist[0][i] =~ /\$/
            alist[0].delete_at(i)
            alist[1].delete_at(i)
            alist[2].delete_at(i)
            alist[3].delete_at(i)
            alist[4].delete_at(i)
          elsif ((alist[1][i] || '').include? 'Preferred') ||
            ((alist[1][i] || '').include? 'Warrant') ||
            ((alist[1][i] || '').include? 'Notes') ||
            ((alist[1][i] || '').include? 'Perp')
            alist[0].delete_at(i)
            alist[1].delete_at(i)
            alist[2].delete_at(i)
            alist[3].delete_at(i)
            alist[4].delete_at(i)
          elsif (alist[2][i] || '').include? 'Y'
            alist[0].delete_at(i)
            alist[1].delete_at(i)
            alist[2].delete_at(i)
            alist[3].delete_at(i)
            alist[4].delete_at(i)
          elsif (alist[3][i] || '').include? 'Y'
            alist[0].delete_at(i)
            alist[1].delete_at(i)
            alist[2].delete_at(i)
            alist[3].delete_at(i)
            alist[4].delete_at(i)
          end
        end
      end

      #remove empty values
      alist.reject! { |c| c.empty? }

      #read through arrays
      (0...nsymbol.length).each do |i|
        symb.push(alist[0][i])
        names.push(alist[1][i])
      end

      #remove first + last from array
      symb.pop
      symb.shift
      names.pop
      names.shift

      #format symbols to be like "AAPL, GOOG"
      #symb.map { |i| i.to_s }.join(",")

#      escaped_page = CGI::escape(symb.map { |i| i.to_s }.join(","))

      puts symb.size

      #pass variables to html.erb
      @Nasdaq = lines
      @nsymbol = nsymbol
      @sname = sname
      @etf = etf
      @testv = testv
      @financials = financials
      @alist = alist
      @symb = symb
      @names = names
    end #end of File open

    #pull json from yahoo finance and parse
    url = 'https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20yahoo.finance.quote%20where%20symbol%20in%20(%22YHOO%2CAAPL%2CGOOG%2CMSFT%22)&format=json&diagnostics=true&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys'
    #sample to put in: %22YHOO%2CAAPL%2CGOOG%2CMSFT%22
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

    puts "Finished!\n\n"
  end

  def about
  end
end
