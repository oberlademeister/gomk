# version stuff
VERSION=$(shell git describe --long --tags --dirty --always)
COMMIT=$(shell git rev-parse HEAD)
BRANCH=$(shell git rev-parse --abbrev-ref HEAD)

# Setup the -ldflags option for go build here, interpolate the variable values
LDFLAGS = -ldflags "-X main.VERSION=${VERSION} -X main.COMMIT=${COMMIT} -X main.BRANCH=${BRANCH}"

BIN = gobin
LINUXBIN = ${BIN}-lin64-${VERSION}
WINBIN = ${BIN}-win64-${VERSION}.exe
LINUXPKG = ${LINUXBIN}.tgz
SRCPKG = ${BIN}-src-${VERSION}.tgz
CFGFILES = gobin.yaml

.PHONY: install

install:
	go install ${LDFLAGS}

${BIN}: *.go
	go build ${LDFLAGS}

${LINUXBIN}: ${BIN}
	GOOS=linux GOARCH=amd64 go build ${LDFLAGS} -o $@

${WINBIN}: ${BIN}
	GOOS=windows GOARCH=amd64 go build ${LDFLAGS} -o $@

${LINUXPKG}: LICENSECITRIX ${LINUXBIN} ${CFGFILES}
	gtar -czvf $@ $< ${LINUXBIN} ${CFGFILES}

${SRCPKG}:
	gtar -czvf $@ *.go *.yaml vendor/ Godeps/

linux-package:	${LINUXPKG}

windows-package: ${WINBIN}

src-package: ${SRCPKG}

push-linux-package: ${LINUXPKG}
	cp ${LINUXPKG} "~/tmp"

push-src-package: ${SRCPKG}
	cp ${SRCPKG} "~/tmp"

clean:
	rm -f ${BIN} 
	rm -f ${BIN}-lin64-*.tgz
	rm -f ${BIN}-lin64-*
	rm -f ${BIN}-win64-*
	rm -f ${BIN}-src-*
	rm -f *.log
	rm -f *.conf
	rm -f *.httplog
	rm -f *.txt
	rm -f *.dot 
	rm -f *.pdf

