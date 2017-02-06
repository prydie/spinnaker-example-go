.PHONY: default
default: compile

OBJECTS=spinnaker-example
VERSION=$(shell ./build/spinnaker-example -v)
ITERATION=$(shell git rev-parse --short HEAD)
BINTRAY_KEY := $(shell echo "$(BINTRAY_KEY)")

.PHONY: compile
compile: $(OBJECTS)

spinnaker-example:
	env GOOS=linux GOARCH=amd64 go build -o ./build/$@

.PHONY: clean
clean:
	rm -rf build

build:
	mkdir $@

build/empty: build
	mkdir $@

.PHONY: generate-init-scripts
generate-init-scripts:
	pleaserun --install \
		--platform systemd \
		--no-install-actions \
		--install-prefix ./build \
		--name spinnaker-example \
		$(PREFIX)/bin/spinnaker-example \

.PHONY: rpm
rpm: AFTER_INSTALL=pkg/centos/after-install.sh
rpm: BEFORE_REMOVE=pkg/centos/before-remove.sh
rpm: PREFIX=/opt/spinnaker-example
rpm: VERSION=$(shell ./build/spinnaker-example -v)
rpm: ITERATION=$(shell git rev-parse --short HEAD)
rpm: clean compile build/empty generate-init-scripts
	fpm -f -s dir -t $@ -n spinnaker-example \
		-p ./build/spinnaker-example-VERSION-ITERATION.ARCH.rpm \
		--version $(VERSION) \
		--iteration $(ITERATION) \
		--architecture native \
		--rpm-os linux \
		--description "a spinnaker example in Go" \
		--url "https://github.com/prydie/spinnaker-example-go" \
		--after-install $(AFTER_INSTALL) \
		--before-remove $(BEFORE_REMOVE) \
		./build/spinnaker-example=$(PREFIX)/bin/ \
		./build/empty/=/var/log/spinnaker-example/ \
		./build/etc/default/spinnaker-example=/etc/default/spinnaker-example \
		./build/etc/systemd/system/spinnaker-example.service=/etc/systemd/system/spinnaker-example.service \

.PHONY: release
release: rpm
	 curl -T $(wildcard ./build/*.rpm) \
		 -uprydie:$(BINTRAY_KEY) \
		 https://api.bintray.com/content/prydie/oracle/spinnaker-example-go/$(VERSION)-$(ITERATION)/$(notdir $(wildcard ./build/*.rpm));publish=1 \
