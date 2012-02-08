module Komixin::Cells
  module Blocks
    def dfp_body(args)
      @id = args[:id]
      render
    end

    def dfp_head
      render
    end
  end
end