# Download the unicode mail list archive from https://corp.unicode.org/pipermail/unicode/

require 'open-uri'
require 'date'

def generate_urls
  base_url = "https://corp.unicode.org/pipermail/unicode/"
  urls = []
  current_date = Date.new(2014, 1, 1)
  end_date = Date.today

  while current_date <= end_date
    year = current_date.year
    month_name = current_date.strftime("%B")

    urls << "#{base_url}#{year}-#{month_name}.txt"
    current_date = current_date.next_month
  end

  urls
end

def download_archive(urls)
  if ARGV.empty?
    puts "Please provide the directory to download the archive"
    return
  end

  urls.each do |url|
    file_name = url.split('/').last
    puts "Downloading #{file_name}..."

    URI.open(url) do |res|
      IO.copy_stream(res, "#{ARGV[0]}/#{file_name}")
    end
  end
end

urls = generate_urls
download_archive(urls)
