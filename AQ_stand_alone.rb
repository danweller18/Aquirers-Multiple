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

download_list

puts "done"
