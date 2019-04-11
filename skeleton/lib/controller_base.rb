require 'active_support'
require 'active_support/core_ext'
require 'active_support/inflector'
require 'erb'
require_relative './session'
require 'byebug'

class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res)
    @req = req
    @res = res
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  # Set the response status code and header
  def redirect_to(url)
    raise "already rendered" if already_built_response?
    @already_built_response = true
    @res.location = url
    @res.status =  302
    @session.store_session(@res)
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
      raise "already rendered" if already_built_response?
      @already_built_response = true
      @res.write(content)
      @res["Content-Type"] = content_type
      @session.store_session(@res)
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    dir = File.dirname(__FILE__)
    new_dir = dir.split('/')
    new_dir = new_dir[0...-1]
    dir = new_dir.join('/')
    path_to_file = File.join(dir,"/views/#{self.class.name.underscore}/#{template_name}.html.erb")
    erb_content = File.read(path_to_file)
    content = ERB.new(erb_content).result(binding)
    render_content(content,'text/html')
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(@req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
  end
end

