KEY_ID ?= "<YOUR_KEY_ID>"
ISSUER_ID ?= "<YOUR_ISSUER_ID>"
PRIVATE_KEY_PATH ?= "path/to/your/private_key"

CLI_PATH := .build/arm64-apple-macosx/debug/hello-appstore
API_GENERATOR_CLI_PATH := ./swift-openapi-generator
SPEC_URL := https://developer.apple.com/sample-code/app-store-connect/app-store-connect-openapi-specification.zip

GEN_OUTPUT_DIR := Sources/__generated/
CLI_SRC := ./Sources
LOCAL_SPEC_PATH := $(CLI_SRC)/openapi.json

# build CLI
build:
	swift build

# run CLI with the given API Key ID
run:
	$(CLI_PATH) \
		--key-id $(KEY_ID) \
		--issuer-id $(ISSUER_ID) \
		--secret-path $(PRIVATE_KEY_PATH)

build_and_run: build run

# check response JSON for the app metrics
# Note: change <YOUR_TOKEN> and <your_app_id> to appropriate values
metrics_request:
	curl -G \
		-d 'filter[deviceType]=all_iphones' -d 'filter[metricType]=MEMORY' -d 'filter[platform]=iOS' \
		-H 'Authorization: Bearer <YOUR_TOKEN>' \
  "https://api.appstoreconnect.apple.com/v1/apps/<your_app_id>/perfPowerMetrics" > metrics_memory.json

# test generated JWT token with a simple GET request to the AppStoreConnectAPI
test_request:
	curl -G \
	-d "fields[apps]=name" \
		-H 'Authorization: <INSERT JWT HERE>' \
		"https://api.appstoreconnect.apple.com/v1/apps"

# Generate the API schema and the transport layer using swift-openapi-generator CLI
api_schema:
	mkdir -p $(GEN_OUTPUT_DIR)
	curl -fsSL $(SPEC_URL) | bsdtar -xOf - > $(LOCAL_SPEC_PATH)
	$(API_GENERATOR_CLI_PATH) generate \
		$(CLI_SRC)/openapi.json \
		--config $(CLI_SRC)/openapi-generator-config.yaml \
		--output-directory $(GEN_OUTPUT_DIR)
