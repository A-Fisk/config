TARGET = dayview
SRC = main.swift
BUILD_DIR = bin

all: build

build:
	mkdir -p $(BUILD_DIR)
	swiftc -O -parse-as-library -framework SwiftUI -framework AppKit -framework EventKit $(SRC) -o $(BUILD_DIR)/$(TARGET)

install: build
	mkdir -p $(HOME)/.local/bin
	cp $(BUILD_DIR)/$(TARGET) $(HOME)/.local/bin/$(TARGET)

clean:
	rm -rf $(BUILD_DIR)
