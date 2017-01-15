FLAGS := -Xcc -I/usr/local/include -Xlinker -L/usr/local/lib/ -Xswiftc -I/usr/local/include

all: core

clean:
	swift build --clean

core: Sources/*.swift Package.swift
	swift build $(FLAGS)

project:
	swift package generate-xcodeproj -Xcc -I/usr/local/include -Xlinker -L/usr/local/lib/ -Xswiftc -I/usr/local/include

test:
	swift test

prod: FLAGS += --configuration release
prod: core
