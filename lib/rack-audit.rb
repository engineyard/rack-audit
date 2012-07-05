# stdlib
require 'thread'
require 'net/http'
require 'uri'
require 'logger'

# gems
require 'rack'
require 'uuidtools'
require 'multi_json'

class Rack::Audit
  attr_reader :queue, :host, :port, :name, :url

  def initialize(app, name, url, options={})
    @app, @name, @url = app, name, url
    @queue  = Queue.new
    @logger = options[:logger] || Logger.new(STDOUT)

    @consumer = Thread.new do
      loop do
        body = self.queue.pop
        begin
          post(body)
        rescue => e
          self.logger.error("#{e.inspect}\n#{e.backtrace.join("\n\t")}")
        end
      end
    end
  end

  def call(env)
    id = UUIDTools::UUID.random_create.to_s
    log_request(id, env)
    response = @app.call(env)
    log_response(id, response)
    response
  end

  private

  def log_request(id, env)
    request          = Rack::Request.new(env)
    loggable_request = {
      :request_method => request.request_method,
      :url            => request.url,
      :params         => request.params,
      :body           => request.body.read,
      :headers        => env.inject({}) do |r,(k,v)|
        k.match(/^HTTP_/) ? r.merge(k.gsub("HTTP_") => v) : r
      end,
    }

    request.body.rewind

    queue << MultiJson.encode(
      :id      => id,
      :request => loggable_request,
      :time    => Time.new.to_i,
      :from    => self.name,
    )
  end

  def log_response(id, response)
    status, headers, body = response
    full_body = ''
    body.each { |b| full_body += b.to_s; b.rewind if b.respond_to?(:rewind) }
    self.queue << MultiJson.encode(
      :id       => id,
      :response => [status, headers, full_body],
      :time     => Time.new.to_i,
      :from     => self.name,
    )
  end

  def post(body)
    uri = URI.parse(self.url)
    host, port = uri.host, uri.port

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl= (uri.port == 443)

    request = Net::HTTP::Post.new(uri.to_s)
    request["Content-Type"]= "application/json"
    request.body= body

    http.request(request)
  end
end
