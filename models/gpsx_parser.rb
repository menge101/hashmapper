require 'nokogiri'

class GpsxParser
  attr_reader :file

  def initialize(file_path, precision=4)
    @file = Nokogiri::XML(File.open(file_path), 'rb')
    @precision = precision
  end

  def extract_gps_coords
    raise StandardError, 'GPX file has an unsupported version' unless version == '1.1'
    coords = @file.css('trkpt').map { |x| [x.attr('lat').to_f, x.attr('lon').to_f] }
    round_and_uniquify coords
  end

  def round_and_uniquify coords
    if @precision
      coords.each_with_index do |coord,idx|
        if idx == 0
          coord.map! { |val| val.round(@precision) }
        else
          current = coord.map { |val| val.round(@precision) }
          if coords[idx-1] == current
            coords[idx] = nil
          else
            coords[idx] = current
          end
        end
      end
      coords.compact
    else
      coords
    end
  end

  def version
    @file.css('gpx').first.attr('version')
  end

  BYTE_LIMIT = 128

  def self.gpx?(file_path, bytes=BYTE_LIMIT)
    begin
      file = File.open(file_path, 'rb').read(bytes)
      Nokogiri::XML.fragment(file).css('gpx').empty? ^ true
    rescue Errno::EISDIR
      false
    end
  end
end