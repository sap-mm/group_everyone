# Makefile for building the project

app_name=group_everyone
project_dir=$(CURDIR)/../$(app_name)
build_dir=$(project_dir)/build
appstore_dir=$(build_dir)/appstore
sign_dir=$(build_dir)/sign
package_name=$(app_name)
cert_dir=$(HOME)/.nextcloud/certificates
webpack=node_modules/.bin/webpack

clean:
	rm -rf $(sign_dir)
	rm -rf $(build_dir)

release: appstore create-tag

node_modules: package.json

CHANGELOG.md: node_modules
	node_modules/.bin/changelog

.PHONY: appstore
appstore: clean
	mkdir -p $(sign_dir)
	rsync -a \
	--exclude=/docs \
	--exclude=/build/sign \
	--exclude=/translationfiles \
	--exclude=/.tx \
	--exclude=/tests \
	--exclude=/.git \
	--exclude=/.github \
	--exclude=/l10n/l10n.pl \
	--exclude=/CONTRIBUTING.md \
	--exclude=/issue_template.md \
	--exclude=/README.md \
	--exclude=/node_modules \
	--exclude=/.gitattributes \
	--exclude=/.gitignore \
	--exclude=/.scrutinizer.yml \
	--exclude=/.travis.yml \
	--exclude=/Makefile \
	$(project_dir)/ $(sign_dir)/$(app_name)
	tar -czf $(build_dir)/$(app_name).tar.gz \
		-C $(sign_dir) $(app_name)
	@if [ -f $(cert_dir)/$(app_name).key ]; then \
		echo "Signing package…"; \
		openssl dgst -sha512 -sign $(cert_dir)/$(app_name).key $(build_dir)/$(app_name).tar.gz | openssl base64; \
	fi

