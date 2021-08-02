#!/usr/bin/env bash
cd $(dirname "$0")
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    FTPARCHIVE='apt-ftparchive'
elif [[ "$OSTYPE" == "darwin"* ]]; then
    FTPARCHIVE='./apt-ftparchive'
fi
for dist in big_sur; do
    for arch in darwin-arm64 darwin-arm64e darwin-amd64; do
        echo $dist $arch
	binary=binary-${arch}
    	contents=Contents-${arch}
    	mkdir -p dists/${dist}/main/${binary}
    	rm -f dists/${dist}/{Release{,.gpg},main/${binary}/{Packages{,.xz,.zst},Release{,.gpg}}}
    	cp -a RepoIcon*.png dists/${dist}

    	$FTPARCHIVE --arch ${arch} packages pool/main/${dist} > \
                dists/${dist}/main/${binary}/Packages 2>/dev/null
    	xz -c9 dists/${dist}/main/${binary}/Packages > dists/${dist}/main/${binary}/Packages.xz
    	zstd -q -c19 dists/${dist}/main/${binary}/Packages > dists/${dist}/main/${binary}/Packages.zst

    	$FTPARCHIVE contents pool/main/${dist} > \
		dists/${dist}/main/${contents}
    	xz -c9 dists/${dist}/main/${contents} > dists/${dist}/main/${contents}.xz
    	zstd -q -c19 dists/${dist}/main/${contents} > dists/${dist}/main/${contents}.zst

    	$FTPARCHIVE release -c config/${arch}-basic.conf dists/${dist}/main/${binary} > dists/${dist}/main/${binary}/Release 2>/dev/null
    	$FTPARCHIVE release -c config/${dist}.conf dists/${dist} > dists/${dist}/Release 2>/dev/null

    	gpg -abs -u C59F3798A305ADD7E7E6C7256430292CF9551B0E -o dists/${dist}/Release.gpg dists/${dist}/Release
    done
done
