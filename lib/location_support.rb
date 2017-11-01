module LocationSupport
  def location_covered?(location)
    # Checks if the location is close to Paris (20km)
    Geocoder::Calculations.distance_between([48.85661400000001,2.3522219000000177], location.coordinates) < 20
  end

  def find_location(address)
    Geocoder.search("#{address}, Île-de-France, France")[0]
  end
end
