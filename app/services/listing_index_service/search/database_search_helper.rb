module ListingIndexService::Search::DatabaseSearchHelper

  module_function

  def success_result(count, listings, includes)
    # marketplace_configurations = MarketplaceService::API::Api.configurations.get(community_id: Community.last.id).data
    marketplace_configuration = Community.last.configuration
    distance_system = marketplace_configuration ? marketplace_configuration[:distance_unit].to_sym : nil
    distance_unit = distance_system == :metric ? :km : :miles
    Result::Success.new(
      {count: count, listings: listings.map { |l|
        distance_hash = parse_distance(l, distance_unit)
        ListingIndexService::Search::Converters.listing_hash( l, includes, distance_hash ) 
        }
      }
    )
  end

  def parse_distance(l, distance_unit)
    distance = if distance_unit == :miles
      (l.distance / 1000) / 1.60934
    else
      (l.distance / 1000)
    end
    if(distance.present? && distance_unit.present?)
      { distance: distance, distance_unit: distance_unit }
    else
      {}
    end
  rescue
    {}
  end  

  def fetch_from_db(community_id:, search:, included_models:, includes:)
    where_opts = HashUtils.compact(
      {
        community_id: community_id,
        author_id: search[:author_id],
        deleted: 0,
        listing_shape_id: Maybe(search[:listing_shape_ids]).or_else(nil)
      })

    scope = Listing
    scope = scope.use_homepage_index if !search[:include_closed] && !search[:author_id]
    scope = scope.currently_open unless search[:include_closed]
    listings = scope.where(where_opts)
                 .includes(included_models)
                 .order("listings.sort_date DESC")
                 .paginate(per_page: search[:per_page], page: search[:page])

    success_result(listings.total_entries, listings, includes)
  end

  # TODO: This should probably be rethought when the Indexer and the
  # new Search API is finished and in use
  def needs_db_query?(search)
    search[:author_id].present? || search[:include_closed] == true
  end

  def needs_search?(search)
    [
      :keywords,
      :latitude,
      :longitude,
      :distance_max,
      :sort,
      :listing_shape_id,
      :listing_shape_ids,
      :categories,
      :fields,
      :price_cents,
      :start_date,
      :start_time
    ].any? { |field| search[field].present? }
  end

end
