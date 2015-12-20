class GpsData < ActiveRecord::Base
  validates :data, presence: true
  validates :count, presence: true

  PARSER_CONFIG = YAML.load_file('config/parsers.yml').freeze
  VALID_TYPES = PARSER_CONFIG['parsers'].map { |parser| parser['mime'] }.freeze
  PARSERS = PARSER_CONFIG['parsers'].map { |parser| parser['class']}.freeze
  #VALID_TYPES = %w(application/gpx+xml) # application/vnd.garmin.tcx+xml application/vnd.google-earth.kmz text/csv

  def initialize
    super
    self.data ||= {}
    self.count ||= 0
  end

  def process_uploaded_files(files)
    coordinates = GpsCollection.new
      return_val = handle_uploads(files)
      parsed_data = return_val.delete(:collection)

    if parsed_data.size > 0
      coordinates.load_array(parsed_data)
      coordinates.load_hash(self.data)
      self.data = coordinates.to_hash
      self.count += parsed_data.size
      self.save!
    end
    return_val
  end

  def merge_existing_data(coordinates)
    data.each do |coords|
      coordinates.add_coordinate(GpsCoords.new(coords[:latitude], coords[:longitude], coords[:count]))
    end
    coordinates
  end

  def handle_uploads(files)
    files = [] if files.nil?
    success = 0
    coordinates = Array.new
    files.each do |file|
      actual_file = file[:tempfile]

      PARSERS.each do |parser|
        dynamic_parser = Object.const_get(parser)
        if dynamic_parser.valid? actual_file
          parser = dynamic_parser.new(actual_file)
          coordinates += parser.extract_gps_coords
          success += 1
          break
        end
      end
    end
    { collection: coordinates, success: success, failure: (files.length - success) }
  end

  def self.acceptable_types
    VALID_TYPES.join(',')
  end
end
