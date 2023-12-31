# == Schema Information
#
# Table name: locations
#
#  id             :integer          not null, primary key
#  latitude       :float(24)
#  longitude      :float(24)
#  address        :string(255)
#  google_address :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#  listing_id     :integer
#  person_id      :string(255)
#  location_type  :string(255)
#  community_id   :integer
#
# Indexes
#
#  index_locations_on_community_id  (community_id)
#  index_locations_on_listing_id    (listing_id)
#  index_locations_on_person_id     (person_id)
#

class Location < ApplicationRecord

  belongs_to :person
  belongs_to :listing
  belongs_to :community
  geocoded_by :google_address

  def search_and_fill_latlng(address=nil, locale=APP_CONFIG.default_locale)
    okresponse = false
    geocoder = "http://maps.googleapis.com/maps/api/geocode/json?address="

    if address == nil
      address = self.address
    end

    if address != nil && address != ""
      url = URI.escape(geocoder+address) # rubocop:disable Lint/UriEscapeUnescape
      resp = RestClient.get(url)
      result = JSON.parse(resp.body)

      if result["status"] == "OK"
        self.latitude = result["results"][0]["geometry"]["location"]["lat"]
        self.longitude = result["results"][0]["geometry"]["location"]["lng"]
        okresponse = true
      end
    end
    okresponse
  end

  def as_json(options={})
    super(options.merge(only: [:id, :latitude, :longitude, :address]))
  end

  def coordinates(fuzzy_location)
    if fuzzy_location
      lat, lon = MapService.obfuscated_coordinates(listing_id, latitude, longitude)
      { latitude: lat, longitude: lon }.to_json
    else
      self.to_json
    end
  end
end
