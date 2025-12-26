.PHONY: build clean release test check

export PKG_CONFIG_PATH := /opt/homebrew/opt/icu4c/lib/pkgconfig:$(PKG_CONFIG_PATH)

build:
	cargo build

release:
	cargo build --release

test:
	cargo test

check:
	cargo check

clean:
	cargo clean
