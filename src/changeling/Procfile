web: bundle exec puma -t 5:5 -p ${PORT:-3000} -e ${RACK_ENV:-development}
worker: LIBRATO_AUTORUN=1 bundle exec sidekiq
stream: LIBRATO_AUTORUN=1 bundle exec rake stream:process
monitor_testing: bundle exec rake monitor:testing
