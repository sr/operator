# coding: utf-8
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

      it "redacts queries with non-ASCII, UTF-8 characters" do
        error = %(Query: 'INSERT INTO natural_search_query (account_id, query) values ('109722', 'El niño test 3')')
        redacted = sanitizer.sanitize(error)

        expect(
          redacted
        ).to eq(%(Query: 'INSERT INTO natural_search_query (account_id, query) values ('109722', [REDACTED])'))
      end
    end
  end
end
