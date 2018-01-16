class LoggerService
  LOGFILE = Rails.root.join('runner.log')
  
  def self.log(x)
    timestamp = Time.now.strftime('%Y-%m-%d %H:%M:%S')
    File.open(LOGFILE, 'a') { |f| f.puts("#{timestamp}: #{x}") }
    puts x
  end
end
