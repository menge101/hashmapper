class BaseParser
  def initialize(file_path, precision=4)
    @file = Nokogiri::XML(File.open(file_path), 'rb')
    @precision = precision
  end

  def extract_gps_coords
    raise MethodNotImplemented, 'Method: extract_gps_coords not defined'
  end

  def round_and_uniquify coords
    last = 0
    if @precision
      coords.each_with_index do |coord,idx|
        if idx == 0
          coord.map! { |val| val.round(@precision) }
          last = 0
        else
          current = coord.map { |val| val.round(@precision) }
          if coords[last] == current
            coords[idx] = nil
          else
            coords[idx] = current
            last = idx
          end
        end
      end
      coords.compact
    else
      coords
    end
  end

  def self.valid?
    raise MethodNotImplemented, 'Method: self.valid? not defined'
  end
end

class MethodNotImplemented < StandardError

end