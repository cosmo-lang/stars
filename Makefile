EXECUTABLE = stars
BUILD_DIR = bin

install:
	@echo "Installing Stars as $(SUDO_USER)"
	shards build --release
	rm -rf /usr/local/bin/$(EXECUTABLE)
	cp $(BUILD_DIR)/$(EXECUTABLE) /usr/local/bin/
	crystal spec --fail-fast
	@echo "Successfully installed Stars!"
