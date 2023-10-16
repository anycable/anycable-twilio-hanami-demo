BIN_NAME=twilio-cable
OUTPUT ?= dist/twilio-cable
PROJECT=anycable/twilio-cable
SCENARIO ?= sample

export GO111MODULE=on

ifdef VERSION
	LD_FLAGS="-s -w -X github.com/$(PROJECT)/pkg/version.version=$(VERSION)"
else
	COMMIT := $(shell sh -c 'git log --pretty=format:"%h" -n 1 ')
	VERSION := $(shell sh -c 'git tag -l --sort=-version:refname "v*" | head -n1')
	LD_FLAGS="-s -w -X github.com/$(PROJECT)/pkg/version.sha=$(COMMIT) -X github.com/$(PROJECT)/pkg/version.version=$(VERSION)"
endif

ifndef ANYCABLE_DEBUG
	export ANYCABLE_DEBUG=1
endif

GOBUILD=go build -ldflags $(LD_FLAGS) -a

# Standard build
default: build

# Install current version
install:
	go mod tidy
	go install ./...

build:
	go build -ldflags $(LD_FLAGS) -o $(OUTPUT) cmd/$(BIN_NAME)/main.go

build-clean:
	rm -rf ./dist

run:
	go run -ldflags $(LD_FLAGS) ./cmd/$(BIN_NAME)/main.go

test:
	@go test -count=1 -timeout=30s -race ./...

bin/golangci-lint:
	@test -x $$(go env GOPATH)/bin/golangci-lint || \
		curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $$(go env GOPATH)/bin v1.54.2

lint: bin/golangci-lint
	$$(go env GOPATH)/bin/golangci-lint run

fmt:
	go fmt ./...

call:
	@ruby etc/make_call.rb

vosk-server:
	@docker run --rm -p 5001:5001 alphacep/kaldi-grpc-en:latest

vosk-fake-server:
	@ruby etc/fake_vosk.rb

wsdirector:
	@wsdirector -f etc/fixtures/wsdirector/$(SCENARIO).yml -u ws://localhost:8080/streams
