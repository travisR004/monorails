require 'uri'
require 'cgi'
require 'open-uri'
require 'debugger'

class Params
  attr_reader :params
  # use your initialize to merge params from
  # 1. query string
  # 2. post body
  # 3. route params
  def initialize(req, route_params = {})
    query_params = parse_www_encoded_form(req.query_string) if req.query_string
    body_params = parse_www_encoded_form(req.body) if req.body
    @params = {}

    [query_params, body_params, route_params].compact.each do |params|
      @params.deep_merge(params)
    end
  end

  def [](key)
    @params[key]
  end

  def permit(*keys)
    @permitted ||= []
    @permitted += keys
  end

  def require(key)
    raise AttributeNotFoundError unless @params.include?(key)
  end

  def permitted?(key)
    @permitted.include?(key)
  end

  def to_s
    @params
  end

  class AttributeNotFoundError < ArgumentError; end;

  private
  # this should return deeply nested hash
  # argument format
  # user[address][street]=main&user[address][zip]=89436
  # should return
  # { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }
  def parse_www_encoded_form(www_encoded_form)
    params_hash = {}
    param_array = URI.decode_www_form(www_encoded_form)
    param_array.each do |key_val|
      key = parse_key(key_val.first)
      val = key_val.last
      until key.empty?
        val = {key.pop  => val}
      end
      params_hash = params_hash.deep_merge(val)
    end
    params_hash
  end

  # this should return an array
  # user[address][street] should return ['user', 'address', 'street']
  def parse_key(key)
    key.split(/\]\[|\[|\]/)
  end
end
  class Hash
    def deep_merge(new_hash)
      new_hash.each do |key, val|
        if self[key].is_a?(Hash) && val.is_a?(Hash)
          self[key] = self[key].deep_merge(val)
        else
          self[key] = val
        end
      end
      self
    end
  end

