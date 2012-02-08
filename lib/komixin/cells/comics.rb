module Komixin::Cells
  module Comics
    def show
      @comic = options[:comic]
      render
    end
  end
end