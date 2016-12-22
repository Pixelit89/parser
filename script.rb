require 'rubygems'
require 'nokogiri'
require 'csv'
require 'open-uri'

def parse url, output_file_name
  html = open(url)
  doc = Nokogiri::HTML(html)
  prod_count = doc.xpath('.//*[@id="center_column"]/div[1]/div/div[2]/h1/small').inner_text.split[1].to_f
  pages_count = (prod_count / 20).ceil
  i = 0
  CSV.open(output_file_name + '.csv', 'w') do |result|
    while (i != pages_count) do
      i += 1
      html = open(url + '?p=' + i.to_s)
      doc = Nokogiri::HTML(html)
      doc.xpath('//a[contains(@class, "quick-view")]').each do |x|
        puts x['href']
        html = open(x['href'])
        doc = Nokogiri::HTML(html)
        reg_name = /<span>.*<\/span>/
        name = doc.xpath('//h1[@itemprop="name"]').inner_html.gsub(reg_name, '').strip
        image = doc.xpath('//img[@id="bigpic"]/@src')
        weights = doc.xpath('//*[@class="attribute_name"]')
        n = 0
        prices = []
        doc.xpath('//*[@class="attribute_price"]').inner_text.split.each do |price|
          if price.to_f != 0
            prices.push(price)
          end
        end
        weights.each do |weight|
          arr = ["#{name.to_s} - #{weight.inner_text.strip}", prices[n], image]
          result << arr
          n += 1
        end
      end
    end
  end
end


parse 'http://www.petsonic.com/es/perros/snacks-y-huesos-perro', 'result'
