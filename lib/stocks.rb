require 'pry'
require 'savon'

def stock_price (ticker)
  # create a client for the service
  client = Savon.client(wsdl: 'http://www.webservicex.net/stockquote.asmx?wsdl')
  # call the 'get_quote' operation
  response = client.call(:get_quote, message: { symbol: "#{ticker}" } )
  #get to the meat of response
  cdata = response.body[:get_quote_response][:get_quote_result]
  #convert tages to lambda
  nori_options = { :convert_tags_to => lambda { |tag| tag.snakecase.to_sym } }
  #parse data
  result = Nori.new(nori_options).parse(cdata)
  #get last price
  price = result[:stock_quotes][:stock][:last]
  price = price.to_f
  return price
end

def secondly_loop
  last = Time.now
  while true
    yield
    now = Time.now
    _next = [last + 5,now].max
    sleep (_next-now)
    last = _next
  end
end

useralert = 105.76
def alert (useralert)
  p price = stock_price("AAPL")
  p useralert
  if price == useralert
    #send sms
    puts "ALERT"
  end
end


secondly_loop {alert useralert}
