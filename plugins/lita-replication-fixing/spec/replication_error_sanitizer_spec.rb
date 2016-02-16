require "spec_helper"
require "replication_fixing/replication_error_sanitizer"

module ReplicationFixing
  RSpec.describe ReplicationErrorSanitizer do
    subject(:sanitizer) { ReplicationErrorSanitizer.new }

    describe "#sanitize" do
      it "redacts strings that are not identifiers or numbers" do
        error = %(Query: 'INSERT INTO foo VALUES ('foo@example.com', '1', '1.2')')
        redacted = sanitizer.sanitize(error)

        expect(redacted).to eq(%(Query: 'INSERT INTO foo VALUES ([REDACTED], '1', '1.2')'))
      end
    end
  end
end
