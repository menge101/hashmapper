class GpsCollection
  attr_reader :coordinates

  def initialize
    @coordinates = Hash.new
  end

  def load_hash(values)
    values = {} if values.nil?
    values.each do |coord|
      next if coord.values.include? nil
      begin
        self.add_coordinate(GpsCoords.new(coord['latitude'], coord['longitude'], coord['count']))
      rescue RuntimeError
        puts 'debug here'
      end

    end
  end

  def load_array(values)
    values.each { |row| self.add_coordinate(GpsCoords.new(row[0], row[1])) }
  end

  def process_files(array_of_files)
    files = trim_file_list(array_of_files)
    files.each do |file|
      GpsxParser.new(file[:tempfile]).extract_gps_coords.each do |coord|
        self.add_coordinate(GpsCoords.new(*coord))
      end
    end
  end

  def add_coordinate(gps_coordinate)
    key = gps_coordinate.key
    if @coordinates.key? key
      @coordinates[key].increment gps_coordinate.count
    else
      @coordinates[key] = gps_coordinate
    end
  end

  def to_hash
    @coordinates.values.map{ |x| x.to_hash }
  end

  def trim_file_list(files)
    files.keep_if { |file| GpsxParser::gpx?(file[:tempfile]) }
  end

  def size
    @coordinates.size
  end
end