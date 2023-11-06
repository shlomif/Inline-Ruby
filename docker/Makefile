DOCKERDIR := $(shell pwd)
DOCKERTAG := "perl-inline-ruby"
.PHONY: build run

build:
	"$(DOCKERDIR)"/build.sh "$(DOCKERTAG)"

run:
	docker run -it "$(DOCKERTAG)"