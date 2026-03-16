.PHONY: test

test: test-reader test-writer

test-reader:
	@pandoc -f a2ml.lua sample.a2ml -t html | \
		diff expected.html - >/dev/null 2>&1 && \
		echo "Reader test passed" || \
		echo "Reader test FAILED"

test-writer:
	@pandoc -f a2ml.lua sample.a2ml -t a2ml-writer.lua | \
		diff expected.a2ml - >/dev/null 2>&1 && \
		echo "Writer test passed" || \
		echo "Writer test FAILED"
