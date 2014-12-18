require 'parse_server/raw_ruby_to_jsonable'
require 'json'
module ParseServer
  class App
    def self.call(rack_env)
      new(rack_env).call
    end

    def initialize(rack_env)
      @rack_env = rack_env
    end

    def call
      body   = @rack_env['rack.input'].read
      status = 200
      begin
        json   = RawRubyToJsonable.call(body)
      rescue Parser::SyntaxError
        status = 400
        json   = {name: 'SyntaxError', message: $!.message, backtrace: $!.backtrace}
      end
      [status, {'Content-Type' => 'application/json; charset=utf-8'}, [JSON.dump(json)]]
    end
  end
end
