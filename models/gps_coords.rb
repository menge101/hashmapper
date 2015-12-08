class GpsCoords
  attr_reader :latitude, :longitude, :count

  def initialize(lat, lon, count=1)
    count = 1 if count.nil?
    if ( lat.nil? || lon.nil? )
      raise 'Invalid nil arguments supplied.'
    end

    @latitude = lat
    @longitude = lon
    @count = count
  end

  def increment(value=1)
    @count += value
  end

  def key
    [@latitude, @longitude]
  end

  def <=>(other)
    if self.latitude == other.latitude
      self.longitude <=> other.longitude
    else
      self.latitude <=> other.latitude
    end
  end

  def to_hash
    { latitude: @latitude, longitude: @longitude, count: @count }
  end
end