class Flash
  def initialize(req)
    req.cookies.each do |cookie|
      @cookie = JSON.parse(cookie.value) if cookie.name == '_flash'
    end
    @cookie ||= {}
  end

  def [](key)
    @cookie[key]
  end

  def []=(key, val)
    @cookie[key] = val
  end

  def now

  end

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_flash(res)
    # debugger
    cookie = WEBrick::Cookie.new('_flash', @cookie.to_json)
    res.cookies << cookie
  end
end
end