# stdlib
require 'thread'
require 'net/http'
require 'uri'

# gems
require 'rack'
require 'uuidtools'
require 'multi_json'

class Rack::Audit
  attr_reader :queue, :host, :port, :name
  def initialize(app, name, uri)
    @app   = app
    @queue = Queue.new
    @uri   = URI(uri)
    @host  = @uri.host
    @port  = @uri.port
    @name  = name

    @consumer = Thread.new do
      while true do
        body = @queue.pop
        begin
          post(@uri, body)
        rescue => e
          STDERR.puts e.inspect
        end
      end
    end
  end

  def call(env)
    uuid = UUIDTools::UUID.random_create.to_s
    log_request(uuid, env)
    response = @app.call(env)
    log_response(uuid, response)
    response
  end

  private

  def log_request(uuid, env)
    request          = Rack::Request.new(env)
    loggable_request = {
      :request_method => request.request_method,
      :url            => request.url,
      :params         => request.params,
      :headers        => Rack::Utils::HeaderHash.new(env).to_hash,
    }

    # FIXME: necessary?
    request.body.rewind

    queue << MultiJson.encode(
      :uuid    => uuid,
      :request => loggable_request,
      :time    => Time.new.to_i,
      :from    => name
    )
  rescue => e
    STDERR.puts e.inspect
  ensure
    true
  end

  def log_response(uuid, response)
    status, headers, body = response
    full_body = ''
    body.each { |b| full_body += b.to_s; b.rewind if b.respond_to?(:rewind) }
    queue << MultiJson.encode(
      :uuid     => uuid,
      :response => [status, headers, full_body],
      :time     => Time.new.to_i,
      :from     => name
    )
  rescue => e
    STDERR.puts e.inspect
  ensure
    true
  end

  def post(uri, body)
    req = Net::HTTP::Post.new(uri.to_s)
    req["content-type"] = "application/json"
    req.body = body
    Net::HTTP.start(host, port){|http| http.request(req)}
  end
end
