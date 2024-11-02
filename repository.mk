_repo-clean:
	rm -rf out/_pages/$(BUILD_DIR)
	mkdir -p out/_pages/$(BUILD_DIR)

_repo-html:
	echo '<html><head><title>nfqws-keenetic opkg repository</title></head><body>' > out/_pages/$(BUILD_DIR)/index.html
	echo '<h1>Index of /$(BUILD_DIR)/</h1><hr>' >> out/_pages/$(BUILD_DIR)/index.html
	echo '<pre>' >> out/_pages/$(BUILD_DIR)/index.html
	echo '<a href="../">../</a>' >> out/_pages/$(BUILD_DIR)/index.html
	echo '<a href="Packages">Packages</a>' >> out/_pages/$(BUILD_DIR)/index.html
	echo '<a href="Packages.gz">Packages.gz</a>' >> out/_pages/$(BUILD_DIR)/index.html

	@if [[ "$(BUILD_DIR)" == "openwrt" ]]; then \
  		echo '<a href="Packages.sig">Packages.sig</a>' >> out/_pages/$(BUILD_DIR)/index.html; \
  		echo '<a href="nfqws-keenetic.pub">nfqws-keenetic.pub</a>' >> out/_pages/$(BUILD_DIR)/index.html; \
  	fi

	echo '<a href="$(FILENAME)">$(FILENAME)</a>' >> out/_pages/$(BUILD_DIR)/index.html

	@if [[ -n "$(WEB)" ]]; then \
		echo '<a href="$(WEB)">$(WEB)</a>' >> out/_pages/$(BUILD_DIR)/index.html; \
	fi

	echo '</pre>' >> out/_pages/$(BUILD_DIR)/index.html
	echo '<hr></body></html>' >> out/_pages/$(BUILD_DIR)/index.html

_repo-index:
	echo '<html><head><title>nfqws-keenetic opkg repository</title></head><body>' > out/_pages/index.html
	echo '<h1>Index of /</h1><hr>' >> out/_pages/index.html
	echo '<pre>' >> out/_pages/index.html
	echo '<a href="all/">all/</a>' >> out/_pages/index.html
	echo '<a href="aarch64/">aarch64/</a>' >> out/_pages/index.html
	echo '<a href="mips/">mips/</a>' >> out/_pages/index.html
	echo '<a href="mipsel/">mipsel/</a>' >> out/_pages/index.html
	echo '<a href="openwrt/">openwrt/</a>' >> out/_pages/index.html
	echo '</pre>' >> out/_pages/index.html
	echo '<hr></body></html>' >> out/_pages/index.html

_repository:
	make _repo-clean

	cp "out/$(FILENAME)" "out/_pages/$(BUILD_DIR)/"

	@if [[ -n "$(WEB)" ]]; then \
		cp "out/$(WEB)" "out/_pages/$(BUILD_DIR)/"; \
	fi

	echo "Package: nfqws-keenetic" > out/_pages/$(BUILD_DIR)/Packages
	echo "Version: $(VERSION)" >> out/_pages/$(BUILD_DIR)/Packages

	@if [[ "$(BUILD_DIR)" == "openwrt" ]]; then \
		echo "Depends: iptables, iptables-mod-extra, iptables-mod-nfqueue, iptables-mod-filter, iptables-mod-ipopt, iptables-mod-conntrack-extra, ip6tables, ip6tables-mod-nat, ip6tables-extra" >> out/_pages/$(BUILD_DIR)/Packages; \
	else \
		echo "Depends: iptables, busybox" >> out/_pages/$(BUILD_DIR)/Packages; \
	fi

	echo "Conflicts: tpws-keenetic" >> out/_pages/$(BUILD_DIR)/Packages
	echo "Section: net" >> out/_pages/$(BUILD_DIR)/Packages
	echo "Architecture: $(ARCH)" >> out/_pages/$(BUILD_DIR)/Packages
	echo "Filename: $(FILENAME)" >> out/_pages/$(BUILD_DIR)/Packages
	echo "Size: $(shell wc -c out/$(FILENAME) | awk '{print $$1}')" >> out/_pages/$(BUILD_DIR)/Packages
	echo "SHA256sum: $(shell sha256sum out/$(FILENAME) | awk '{print $$1}')" >> out/_pages/$(BUILD_DIR)/Packages
	echo "Description:  NFQWS service" >> out/_pages/$(BUILD_DIR)/Packages
	echo "" >> out/_pages/$(BUILD_DIR)/Packages

	@if [[ -n "$(WEB)" ]]; then \
		echo "Package: nfqws-keenetic-web" >> out/_pages/$(BUILD_DIR)/Packages; \
		echo "Version: $(VERSION)" >> out/_pages/$(BUILD_DIR)/Packages; \
		echo "Depends: nfqws-keenetic, php8-cgi, php8-mod-session, lighttpd, lighttpd-mod-cgi, lighttpd-mod-setenv, lighttpd-mod-rewrite, lighttpd-mod-redirect" >> out/_pages/$(BUILD_DIR)/Packages; \
		echo "Section: net" >> out/_pages/$(BUILD_DIR)/Packages; \
		echo "Architecture: all" >> out/_pages/$(BUILD_DIR)/Packages; \
		echo "Filename: $(WEB)" >> out/_pages/$(BUILD_DIR)/Packages; \
		echo "Size: $(shell wc -c out/$(WEB) | awk '{print $$1}')" >> out/_pages/$(BUILD_DIR)/Packages; \
		echo "SHA256sum: $(shell sha256sum out/$(WEB) | awk '{print $$1}')" >> out/_pages/$(BUILD_DIR)/Packages; \
		echo "Description:  NFQWS service web interface (Keenetic only)" >> out/_pages/$(BUILD_DIR)/Packages; \
		echo "" >> out/_pages/$(BUILD_DIR)/Packages; \
	fi

	gzip -k out/_pages/$(BUILD_DIR)/Packages

	@make _repo-html

repo-mipsel:
	@make \
		BUILD_DIR=mipsel \
		ARCH=mipsel-3.4 \
		FILENAME=nfqws-keenetic_$(VERSION)_mipsel-3.4.ipk \
		WEB=nfqws-keenetic-web_$(VERSION)_all_entware.ipk \
		_repository

repo-mips:
	@make \
		BUILD_DIR=mips \
		ARCH=mips-3.4 \
		FILENAME=nfqws-keenetic_$(VERSION)_mips-3.4.ipk \
		WEB=nfqws-keenetic-web_$(VERSION)_all_entware.ipk \
		_repository

repo-aarch64:
	@make \
		BUILD_DIR=aarch64 \
		ARCH=aarch64-3.10 \
		FILENAME=nfqws-keenetic_$(VERSION)_aarch64-3.10.ipk \
		WEB=nfqws-keenetic-web_$(VERSION)_all_entware.ipk \
		_repository

repo-multi:
	@make \
		BUILD_DIR=all \
		ARCH=all \
		FILENAME=nfqws-keenetic_$(VERSION)_all_entware.ipk \
		WEB=nfqws-keenetic-web_$(VERSION)_all_entware.ipk \
		_repository

repo-openwrt:
	@make \
		BUILD_DIR=openwrt \
		ARCH=all \
		FILENAME=nfqws-keenetic_$(VERSION)_all_openwrt.ipk \
		_repository

repository: repo-mipsel repo-mips repo-aarch64 repo-multi repo-openwrt _repo-index
