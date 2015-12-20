class GpsxParser < BaseParser
  def extract_gps_coords
    coords = @file.css('trkpt').map { |x| [x.attr('lat').to_f, x.attr('lon').to_f] }
    round_and_uniquify coords
  end

  BYTE_LIMIT = 128

  def self.valid?(file_path, bytes=BYTE_LIMIT)
    begin
      file = File.open(file_path, 'rb').read(bytes)
      Nokogiri::XML.fragment(file).css('gpx').empty? ^ true
    rescue Errno::EISDIR
      false
    end
  end
end