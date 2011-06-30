module ActionController
  module Routing
    class RouteSet
      def extract_request_environment(request)
        {
          :method => request.method, :subdomain => request.host.split(".").first,
          :hostname => request.host, :url => request.url, :relative_url => URI.parse(request.url).request_uri
        }
      end
    end
    class Route
      alias_method :old_recognition_conditions, :recognition_conditions

      # Adds conditions to route matches with given information and comparator method.
      #
      # ==== Criterion
      # * <tt>:subdomain</tt> - compares subdomain with the request url
      # * <tt>:hostname</tt> - compares hostname with the request url
      # * <tt>:relative_url</tt> - compares relative url with the request url
      # * <tt>:url</tt> - compares the entire request url.
      # * Only of the given four criterion is acceptable with one route.
      #
      # ==== :comparator options
      # * <tt>:direct_match</tt> - exactly matches the criteria. This is default comparator.
      # * <tt>:starts_with</tt> - matches the start of the criterion.
      # * <tt>:ends_with</tt> - matches the end of criterion.
      # * <tt>:contains</tt> - matches the substring of criterion.
      # * <tt>:match</tt> - alias of regex.
      # * <tt>:regex</tt> - matches the regular expression with the criterion.
      # * Only of the given comparators are acceptable.
      #
      # ==== Examples
      #   map.connect "/:id", :controller => 'main', :action => 'index', :conditions=> {:subdomain => "tv", :comparator=>"direct_match"}
      #
      #   map.connect "/:id", :controller => 'main', :action => 'index', :conditions=> {:subdomain => "tv", :comparator=>"starts_with"}
      #
      #   map.connect "/:id", :controller => 'main', :action => 'index', :conditions=> {:subdomain => /tv/i, :comparator=>"regex"}
      #
      #   map.connect "/:id", :controller => 'main', :action => 'index', :conditions=> {:hostname => "tv.naitazi", :comparator=>"starts_with"}
      #
      #   map.connect "/:id", :controller => 'main', :action => 'index', :conditions=> {:hostname => "naitazi.com", :comparator=>"ends_with"}
      #
      #   map.connect "/:id", :controller => 'main', :action => 'index', :conditions=> {:relative_url => "/my-detail-page"}
      #
      #   map.connect "/:id", :controller => 'main', :action => 'index', :conditions=> {:relative_url => /detail/i, :comparator=>"regex"}
      #
      #   map.connect "/:id", :controller => 'main', :action => 'index', :conditions=> {:url => "http://www.pakwheels", :comparator=>"starts_with"}
      #
      #   map.connect "/:id", :controller => 'main', :action => 'index', :conditions=> {:url => "pakwheels.com", :comparator=>"ends_with"}
      
      def recognition_conditions
        allowed_keys = [:hostname, :subdomain, :url, :relative_url]
        used_criterion = conditions.keys&allowed_keys
        raise RuntimeError.new("Only one of the :hostname, :subdomain, :url, :relative_url is allowed!!!") if used_criterion.size > 1
        result = old_recognition_conditions

        comparator_hash = {:contains=>".include?", :starts_with => ".starts_with?", :ends_with => ".ends_with?",
          :regex => " =~ ", :match => " =~ "}.stringify_keys

        method_name = comparator_hash[conditions[:comparator].to_s]||"==="

        criterion = used_criterion.first
        
        result << "(env[:#{criterion}]||\"\")#{method_name}(conditions[:#{criterion}])" if conditions[criterion]
        result
      end
    end
  end
end
