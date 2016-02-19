test: \
	test-plugin-lita-replication-fixing

test-plugin-%:
	cd "plugins/$*"; bundle exec rspec $(SPEC)
