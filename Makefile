test: \
	test-plugin-lita-replication-fixing \
	test-plugin-lita-zabbix

test-plugin-%:
	cd "plugins/$*"; bundle exec rspec $(SPEC)
