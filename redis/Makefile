start-server:
	ruby -Ivendor/bundle daemon.rb start

test:
	ruby redis_server_test.rb

test-decoder:
	ruby resp_decoder_test.rb

stop-server:
	# kill -9 $(lsof -i tcp:6380 -t)
	ruby -Ivendor/bundle daemon.rb stop


.PHONY: test
