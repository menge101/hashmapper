class KmlParser < BaseParser
  def extract_gps_coords
    coords = @file.css('coordinates').map { |coord| coord.text }.join(' ').split(' ')
    coords.map! { |coord| coord.split ',' }
    coords.map! { |coord| [coord[1].to_f, coord[0].to_f] }
    round_and_uniquify coords
  end

  BYTE_LIMIT = 128

  def self.valid?(file_path, bytes=BYTE_LIMIT)
    begin
      file = File.open(file_path, 'rb').read(bytes)
      Nokogiri::XML.fragment(file).children.map { |x| x.name }.include? 'kml'
    rescue Errno::EISDIR
      false
    end
  end
end