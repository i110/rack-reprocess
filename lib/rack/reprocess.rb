require "rack/reprocess/version"

module Rack
  RACK_REPROCESS_STACK = 'roomclip.reprocess.stack'.freeze

  class Reprocessable
    def initialize(app)
      @app = app
    end
    def call(env)
      env[RACK_REPROCESS_STACK] ||= []
      env[RACK_REPROCESS_STACK].push({
        :app         => @app,
        :script_name => env[SCRIPT_NAME],
      })
      res = @app.call(env)
      env[RACK_REPROCESS_STACK].pop
      res
    end
  end

  class Reprocess
    def initialize(path = nil, &blk)
      @path = path
      @blk = blk
    end
    def call(env)
      unless stack = env[RACK_REPROCESS_STACK]
        raise 'Rack::Reprocessable is not used in your application'
      end

      script_name = stack.last[:script_name]
      path = @path || @blk.call(env)
      unless path.index(script_name) == 0 && (path[script_name.size] == ?/ ||
                                              path[script_name.size].nil?)
        raise ArgumentError, "can only include below #{script_name}, not #{path}"
      end

      path_info = path.gsub(/^#{script_name}/, '')
      stack.last[:app].call(env.merge({ SCRIPT_NAME => script_name, PATH_INFO => path_info}))
    end
  end
end
