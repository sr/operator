.PHONY: \
	proto

proto:
	go get -u github.com/golang/protobuf/{proto,protoc-gen-go}
	protoc --go_out=plugins=grpc:. src/services/*/service.proto
