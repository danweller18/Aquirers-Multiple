class StaticPagesController < ApplicationController
  def home
    require 'net/ftp'

    # Login to the FTP server
    ftp = Net::FTP.new('ftp.nasdaqtrader.com')
    ftp.login('anonymous', '')

    # Switch to the desired directory
    ftp.chdir('SymbolDirectory')

    # Get the file we need and save it to our 'ftp_tickers' directory
    ftp.getbinaryfile('nasdaqtraded.txt', 'ftp_tickers/nasdaqtraded.txt')
  end

  def stocks
    require 'cgi'
    require 'open-uri'
    require 'net/ftp'
    require "erb"
    require 'oauth_util.rb'
    require 'net/http'

    #o = OauthUtil.new
    #o.consumer_key = "dj0yJmk9ZU8zdHBVZUJycFRnJmQ9WVdrOVJXaFdSRTAxTnpJbWNHbzlNQS0tJnM9Y29uc3VtZXJzZWNyZXQmeD00Mg--"
    #o.consumer_secret = "64dabdfa4fe63f40317d1496501938d45c6ce699"

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
    etfs = []
    testvs = []
    financialss = []
    symb1 = []
    symb2 = []
    symb3 = []
    symb4 = []
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

      #read through arrays
      (0...nsymbol.length).each do |i|
        symb.push(alist[0][i])
        names.push(alist[1][i])
        etfs.push(alist[2][i])
        testvs.push(alist[3][i])
        financialss.push(alist[4][i])
      end

      #remove first + last from array
      symb.pop
      symb.shift
      names.pop
      names.shift
      etfs.pop
      etfs.shift
      testvs.pop
      testvs.shift
      financialss.pop
      financialss.shift

      #split array into four new arrays
      (0...symb.size/4).each do |i|
        symb1.push(symb[i])
      end
      (symb.size/4...((symb.size/4)*2)).each do |i|
        symb2.push(symb[i])
      end
      (((symb.size/4)*2)...((symb.size/4)*3)).each do |i|
        symb3.push(symb[i])
      end
      (((symb.size/4)*3)...((symb.size/4)*4)).each do |i|
        symb4.push(symb[i])
      end

      #format symbols to be like "AAPL, GOOG"
      #symb.map { |i| i.to_s }.join(",")

#      escaped_page = CGI::escape(symb.map { |i| i.to_s }.join(","))

      p "Original #{symb.size}"
      p "symb1 #{symb1.size}"
      p "symb2 #{symb2.size}"
      p "symb3 #{symb3.size}"
      p "symb4 #{symb4.size}"

      p ERB::Util.url_encode "My Blod & Your Blog"

    #@symb1 = symb1
      #p ERB::Util.url_encode symb1.map { |i| i.to_s }.join(",")

    #  @urlbeg = "https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20yahoo.finance.quote(0%2C5000)%20where%20symbol%20in%20(%22"

    #  @urlend = "%22)&format=json&diagnostics=true&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys"

      #{foo: 'asd asdf', bar: '"<#$dfs'}.to_param

      #puts "#{urlbeg}#{ERB::Util.url_encode symb1.map { |i| i.to_s }.join(",")}#{urlend}"

      #pass variables to html.erb
    #  @Nasdaq = lines
    #  @nsymbol = nsymbol
    #  @sname = sname
    #  @etf = etf
    #  @testv = testv
    #  @financials = financials
    #  @alist = alist
    #  @symb = symb
    #  @names = names
    #  @etfs = etfs
    #  @testvs = testvs
    #  @financialss = financialss
    end #end of File open

    #p  url = "#{@urlbeg}#{ERB::Util.url_encode @params.map { |i| i.to_s }.join(",")}#{@urlend}"

    url = 'https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20yahoo.finance.quote%20where%20symbol%20in%20(%22YHOO%2CAAPL%2CGOOG%2CMSFT%22)&format=json&diagnostics=true&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys'
    parsed_url = URI.parse( url )

    #p parsed_url.query

    p @params

    consumer = OAuth::Consumer.new("dj0yJmk9ZU8zdHBVZUJycFRnJmQ9WVdrOVJXaFdSRTAxTnpJbWNHbzlNQS0tJnM9Y29uc3VtZXJzZWNyZXQmeD00Mg--", "64dabdfa4fe63f40317d1496501938d45c6ce699", :site => "https://query.yahooapis.com/")

    Net::HTTP.start( parsed_url.host ) { | http |
      req = Net::HTTP::Get.new "#{ parsed_url.path }?#{ o.sign(parsed_url).query_string }"
      response = http.request(req)
      @data1 = response.body
    }

    #req = Net::HTTP.get_response(parsed_url)

    #render :text => "<pre>" + JSON.pretty_generate(data1)


#    Net::HTTP.start( parsed_url.host ) { | http |
      #req = Net::HTTP::Get.new "#{ parsed_url.path }?#{ o.sign(parsed_url).query_string }"
      #response = http.request(req)
      #print response.read_body
#    }

    #pull json from yahoo finance and parse
    #url = 'https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20yahoo.finance.quote%20where%20symbol%20in%20(%22YHOO%2CAAPL%2CGOOG%2CMSFT%22)&format=json&diagnostics=true&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys'
    #sample to put in: %22YHOO%2CAAPL%2CGOOG%2CMSFT%22
    #file = open(url).read
    #data = JSON.parse(file)
#    data = JSON.parse(response.read_body)

    p data = JSON.parse(@data1)

    #p data
    render :text => "<pre>" + JSON.pretty_generate(data)



    #put results into arrays
    array1 = data['query']['results']
    #check for nil
    unless array1.nil?
      array2 = array1['quote']
    end

    p array2[0]['symbol']

    #create symbol array and push symbols into it
    symbol = []
    #for i in 0..@params.size
    for i in 0..3
      unless array2.nil?
        j = array2[i]['symbol'];
        symbol.push(j)
      end
    end
    #Global variable holds symbol array
    @Symbols = symbol

    #create price array and push prices into it
    price = []
#    for i in 0..@params.size
    for i in 0..3
      unless array2.nil?
        j = array2[i]['LastTradePriceOnly'];
        price.push(j)
      end
    end
    #Global variable holds prices array
    @Prices = price

    puts "Finished!\n\n"
  end

  def about
  end

  def new
    render :text => "<pre>" + env["omniauth.auth"].to_yaml
    #raise request.env["omniauth.auth"].to_yaml
  end
end
