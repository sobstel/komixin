module Komixin
  class JsonResponse
    attr_accessor :success, :msg, :args

    def initialize(args)
      args ||= {}
      @success = args.delete(:success) || true
      @msg = args.delete(:msg) || ""
      @args = args
    end

    def inspect
      { :s => @success ? 1 : 0, :m => msg, :a => @args }
    end

    def as_json(options={})
      self.inspect.as_json(options)
    end
  end
end