if defined?(WillPaginate)
  module WillPaginate
    module ActiveRecord
      module RelationMethods
        alias_method :per, :per_page
        alias_method :num_pages, :total_pages
        alias_method :prev_page, :previous_page
        def total_count() count end
        def first_page?() self == first end
        def last_page?() self == last end
      end
    end
    module CollectionMethods
      alias_method :num_pages, :total_pages
    end
  end
end
