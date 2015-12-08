class GpsData < ActiveRecord::Base
  validates :data, presence: true
  validates :count, presence: true

  VALID_TYPES = %w(application/gpx+xml) # application/vnd.garmin.tcx+xml application/vnd.google-earth.kmz text/csv

  def initialize
    super
    self.data = {}
    self.count = 0
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
    end

    self.save!
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
    success = rejected = 0
    coordinates = Array.new
    files.each do |file|
      actual_file = file[:tempfile]
      if GpsxParser::gpx? actual_file
        parser = GpsxParser.new(file[:tempfile])
        coordinates += parser.extract_gps_coords
        success += 1
      else
        rejected += 1
      end
    end
    { collection: coordinates, success: success, failure: rejected }
  end

  def self.acceptable_types
    VALID_TYPES.join(',')
  end
end