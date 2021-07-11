start-server:
	ruby -Ivendor/ruby/2.7.0/gems/**/lib daemon.rb start

test:
	ruby redis_server_test.rb

test-decoder:
	ruby resp_decoder_test.rb

stop-server:
	# kill -9 $(lsof -i tcp:6380 -t)
	ruby -Ivendor/ruby/2.7.0/gems/**/lib daemon.rb stop


.PHONY: test
