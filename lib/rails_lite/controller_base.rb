require 'erb'
require 'active_support/inflector'
require_relative 'params'
require_relative 'session'
require 'active_support/core_ext'
require 'debugger'
class ControllerBase
  attr_reader :params, :req, :res

  # setup the controller
  def initialize(req, res, route_params = {})
    @req, @res = req, res
    p route_params
    @params = Params.new(req, route_params)
    p "After Params.new"
    p @params
  end

  # populate the response with content
  # set the responses content type to the given type
  # later raise an error if the developer tries to double render
  def render_content(content, type)
    raise "Already Rendered" if already_rendered?
    @res.content_type = type
    @res.body = content
    @session.store_session(@res) if @session
    @already_built_response = true

  end

  # helper method to alias @already_rendered
  def already_rendered?
    @already_built_response
  end

  # set the response status code and header
  def redirect_to(url)
    raise "Rendered" if already_rendered?
    @res.status = 302
    @res["location"] = url
    @session.store_sesssion(@res) if @session
    @already_built_response = true
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    controller_name = self.class.to_s.underscore
    contents = File.read("views/#{controller_name}/#{template_name}.html.erb")
    erb_template = ERB.new(contents).result(binding)
    render_content(erb_template, "text/html")
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(@req)
  end

  def flash
    @flash ||= Flash.new(@req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    send(name)
    render(name) unless already_rendered?
  end
end
