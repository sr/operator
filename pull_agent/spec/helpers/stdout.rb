module TestHelpers
  module Stdout
    def capturing_stdout
      orig_stdout = $stdout
      begin
        $stdout = StringIO.new
        yield
        $stdout.string
      ensure
        $stdout = orig_stdout
      end
    end
  end
end
