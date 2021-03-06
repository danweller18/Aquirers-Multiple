def download_list
  require 'net/ftp'
  require 'date'

  #obtain the date
  date = Date.today
  date = date.to_s

  # Login to the FTP server
  ftp = Net::FTP.new('ftp.nasdaqtrader.com')
  ftp.login('anonymous', '')

  # Switch to the desired directory
  ftp.chdir('SymbolDirectory')

  # Get the file we need and save it to our 'ftp_tickers' directory
  ftp.getbinaryfile('nasdaqtraded.txt', 'nasdaqtraded_'+ date + '.txt')
end

def security_list
  require 'date'
  require 'open-uri'
  require 'json'

  #obtain the date
  date = Date.today
  date = date.to_s

  lines = []
  nsymbol = []
  sname = []
  etf = []
  testv = []
  financials = []
  alist = []
  symb = []
  filename = 'nasdaqtraded_'+ date + '.txt'
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
          ((alist[1][i] || '').include? 'Perp') ||
          ((alist[1][i] || '').include? 'Debentures') ||
          ((alist[1][i] || '').include? 'ETN') ||
          ((alist[1][i] || '').include? 'Exchange') ||
          ((alist[1][i] || '').include? 'Futures')
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

    #read through array
    (0...nsymbol.length).each do |i|
      symb.push(alist[0][i])
    end

    #remove first + last from array
    symb.pop
    symb.shift

    #puts symb

    #pull json from yahoo finance and parse
    url = 'https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20yahoo.finance.quote%20where%20symbol%20in%20(%22YHOO%2CAAPL%2CGOOG%2CMSFT%22)&format=json&diagnostics=true&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys'
    #sample to put in: %22YHOO%2CAAPL%2CGOOG%2CMSFT%22
    file = open(url).read
    data = JSON.parse(file)

    #put results into arrays
    array1 = data['query']['results']
    #check for nil
    unless array1.nil?
      array2 = array1['quote']
    end

    #print out names
    for i in 0..3
      p array2[i]['symbol']
    end


  end #end of File open
end

##run everything################################################################
download_list
security_list

puts "done"
