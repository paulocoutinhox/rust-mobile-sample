# Makefile to compile a Rust project for all iOS architectures, including devices and simulators, and for Android.

# General settings
PROJECT_NAME := YourProject
RUSTC_IOS_TARGETS := aarch64-apple-ios
RUSTC_IOS_SIMULATOR_TARGETS := aarch64-apple-ios-sim x86_64-apple-ios
RUSTC_IOS_MACCATALYST_TARGET := #aarch64-apple-ios-macabi x86_64-apple-ios-macabi
RUSTC_TVOS_TARGETS := #aarch64-apple-tvos x86_64-apple-tvos
RUSTC_TVOS_SIMULATOR_TARGETS := #$(shell xcrun simctl list devices | grep -Eo ' [0-9A-F-]+ ' | xargs -I {} echo aarch64-apple-tvos-simulator{} x86_64-apple-tvos-simulator{})
RUSTC_WATCHOS_TARGETS := #armv7k-apple-watchos thumbv7k-apple-watchos
RUSTC_WATCHOS_SIMULATOR_TARGETS := #$(shell xcrun simctl list devices | grep -Eo ' [0-9A-F-]+ ' | xargs -I {} echo aarch64-apple-watchos-simulator{} x86_64-apple-watchos-simulator{})
RUSTC_ANDROID_TARGETS := aarch64-linux-android

# Directories
SRC_DIR := src
BUILD_DIR := target
IOS_BUILD_DIR := $(BUILD_DIR)/ios
ANDROID_BUILD_DIR := $(BUILD_DIR)/android/libs

# Commands
CARGO := cargo

.PHONY: all ios android setup-targets

all: ios android

ios: $(IOS_BUILD_DIR)/$(PROJECT_NAME).xcframework

android: $(addprefix $(ANDROID_BUILD_DIR)/,$(addsuffix /release/lib$(PROJECT_NAME).so,$(RUSTC_ANDROID_TARGETS)))

# Compilation for iOS (XCFramework)
$(IOS_BUILD_DIR)/$(PROJECT_NAME).xcframework: $(addprefix $(IOS_BUILD_DIR)/,$(RUSTC_IOS_TARGETS) $(RUSTC_IOS_SIMULATOR_TARGETS) $(RUSTC_IOS_MACCATALYST_TARGET) $(RUSTC_TVOS_TARGETS) $(RUSTC_TVOS_SIMULATOR_TARGETS) $(RUSTC_WATCHOS_TARGETS) $(RUSTC_WATCHOS_SIMULATOR_TARGETS))
	# Here, you should create the XCFramework with the generated binaries.
	# Make sure to differentiate between devices and simulators when creating the XCFramework.

# Compilation for iOS (devices)
$(IOS_BUILD_DIR)/%: TARGET = $(patsubst $(IOS_BUILD_DIR)/%,%,$@)
$(IOS_BUILD_DIR)/%: $(SRC_DIR)/Cargo.toml
	@mkdir -p $(IOS_BUILD_DIR)
	$(CARGO) build --release --target=$(TARGET) --manifest-path=$(SRC_DIR)/Cargo.toml

# Compilation for iOS (simulators)
$(IOS_BUILD_DIR)/%-simulator: TARGET = $(patsubst $(IOS_BUILD_DIR)/%-simulator,%,$@)
$(IOS_BUILD_DIR)/%-simulator: $(SRC_DIR)/Cargo.toml
	@mkdir -p $(IOS_BUILD_DIR)
	$(CARGO) build --release --target=$(TARGET) --manifest-path=$(SRC_DIR)/Cargo.toml

# Compilation for Android
$(ANDROID_BUILD_DIR)/%/release/lib$(PROJECT_NAME).so: TARGET = $(patsubst $(ANDROID_BUILD_DIR)/%/release/lib$(PROJECT_NAME).so,%,$@)
$(ANDROID_BUILD_DIR)/%/release/lib$(PROJECT_NAME).so: $(SRC_DIR)/Cargo.toml
	@mkdir -p $(dir $@)
	$(CARGO) build --release --target=aarch64-linux-android --manifest-path=$(SRC_DIR)/Cargo.toml

# Target to install all necessary targets
setup-targets:
	rustup target add $(RUSTC_IOS_TARGETS) $(RUSTC_IOS_SIMULATOR_TARGETS) $(RUSTC_IOS_MACCATALYST_TARGET) $(RUSTC_TVOS_TARGETS) $(RUSTC_TVOS_SIMULATOR_TARGETS) $(RUSTC_WATCHOS_TARGETS) $(RUSTC_WATCHOS_SIMULATOR_TARGETS) $(RUSTC_ANDROID_TARGETS)

clean:
	$(CARGO) clean
	rm -rf $(BUILD_DIR)

# Add other targets and commands as needed.
