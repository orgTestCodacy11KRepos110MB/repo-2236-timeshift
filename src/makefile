SHELL=/bin/bash
CFLAGS=--std=c99
EXECUTABLES = find msgmerge msgfmt install rm mkdir cp chmod valac
CHECKEXECS := $(foreach exec,$(EXECUTABLES), $(if $(shell which $(exec)),,$(error No $(exec) found, install it)))

prefix=/usr
sysconfdir=/etc
appconfdir=$(sysconfdir)/timeshift
bindir=$(prefix)/bin
sharedir=$(prefix)/share
polkitdir=$(sharedir)/polkit-1/actions
localedir=$(sharedir)/locale
launcherdir=$(sharedir)/applications
mandir=$(sharedir)/man
man1dir=$(mandir)/man1

app_name=timeshift
app_fullname=Timeshift

# vte -----------------------------

vte_symbol = -D VTE_291
vte_version=$(shell { (pkg-config --modversion vte-2.91 | cut -d. -f2); } )

ifeq ($(shell { test ${vte_version} -lt 52 ; echo $$? ; } ), 0)
vte_symbol=$(shell echo '-D VTE_291_OLD')
else
vte_symbol=$(shell echo '-D VTE_291')
endif

# xapp -----------------------------

xapp_pkg=$(shell { ((pkg-config --exists 'xapp >= 1.0.4') >/dev/null && echo '--pkg xapp') || echo ''; } )
xapp_symbol=$(shell { ((pkg-config --exists 'xapp >= 1.0.4') >/dev/null && echo '-D XAPP') || echo ''; } )

# gtk3 -----------------------------

gtk3_version=$(shell { (pkg-config --modversion gtk+-3.0 | cut -d. -f2); } )

ifeq ($(shell { test ${gtk3_version} -gt 17 ; echo $$? ; } ), 0)
gtk3_symbol=$(shell echo '-D GTK3_18')
else
gtk3_symbol=$(shell echo '')
endif

symbols=$(shell echo "${vte_symbol} ${gtk3_symbol} ${xapp_symbol}")

all: app-gtk app-console

app-gtk:

	#timeshift-gtk
	valac -X -D'GETTEXT_PACKAGE="${app_name}"' \
		--Xcc="-lm" --Xcc="-Os" ${symbols} \
		Core/*.vala Gtk/*.vala Utility/*.vala Utility/Gtk/*.vala \
		-o ${app_name}-gtk \
		--pkg glib-2.0 --pkg gio-unix-2.0 --pkg posix \
		--pkg gee-0.8 --pkg json-glib-1.0 --pkg gio-2.0 \
		--pkg gtk+-3.0 --pkg vte-2.91 $(xapp_pkg)

app-console:

	#timeshift
	valac -X -D'GETTEXT_PACKAGE="${app_name}"' \
		--Xcc="-lm" --Xcc="-Os" ${symbols} \
		Core/*.vala Utility/*.vala Utility/Gtk/*.vala Console/*.vala \
		-o ${app_name} \
		--pkg glib-2.0 --pkg gio-unix-2.0 --pkg posix \
		--pkg gee-0.8 --pkg json-glib-1.0 --pkg gio-2.0 \
		--pkg gtk+-3.0 --pkg vte-2.91 $(xapp_pkg)

manpage:
	./${app_name} --help > ../man/${app_name}.1
	gzip -f ../man/${app_name}.1
	
pot:

	# update translation template
	find . -iname "*.vala" | xargs xgettext \
		--from-code=UTF-8 --language=C --keyword=_ \
		--copyright-holder='Tony George (teejeetech@gmail.com)' \
		--package-name="${app_name}" \
		--package-version='18.2' \
		--msgid-bugs-address='teejeetech@gmail.com' \
		--escape --sort-output \
		-o ../${app_name}.pot

	# translations
	for lang in am ar az bg ca cs da de el en_GB es et eu fi fr he hi hr hu ia id is it ja ko lt nb ne nl pl pt pt_BR ro ru sk sr sv tr uk vi zh_CN zh_TW; do \
		msgmerge --update -v ../po/${app_name}-$$lang.po ../${app_name}.pot ; \
	done
	
clean:
	rm -rfv ../release/{source,i386,amd64,armel,armhf}
	rm -rfv ../release/*.{run,deb}
	rm -rfv *.c *.o *.mo
	rm -fv ${app_name} ${app_name}-gtk
	
install:
	mkdir -p "$(DESTDIR)$(bindir)"
	mkdir -p "$(DESTDIR)$(sharedir)"
	mkdir -p "$(DESTDIR)$(mandir)"
	mkdir -p "$(DESTDIR)$(man1dir)"
	mkdir -p "$(DESTDIR)$(launcherdir)"
	mkdir -p "$(DESTDIR)$(polkitdir)"
	mkdir -p "$(DESTDIR)$(sysconfdir)"
	mkdir -p "$(DESTDIR)$(appconfdir)"
	mkdir -p "$(DESTDIR)$(sharedir)/${app_name}"
	mkdir -p "$(DESTDIR)$(sharedir)/icons"
	mkdir -p "$(DESTDIR)$(sharedir)/appdata" 
	mkdir -p "$(DESTDIR)$(sharedir)/metainfo"
	mkdir -p "$(DESTDIR)$(sharedir)/pixmaps"
	
	# binary
	install -m 0755 ${app_name} "$(DESTDIR)$(bindir)"
	install -m 0755 ${app_name}-gtk "$(DESTDIR)$(bindir)"
	#install -m 0755 ${app_name}-uninstall "$(DESTDIR)$(bindir)"
	install -m 0755 ${app_name}-launcher "$(DESTDIR)$(bindir)"
	
	# shared files
	cp -dpr --no-preserve=ownership -t "$(DESTDIR)$(sharedir)/${app_name}" ./share/${app_name}/*
	find $(DESTDIR)$(sharedir)/${app_name} -type d -exec chmod 755 {} \+
	find $(DESTDIR)$(sharedir)/${app_name} -type f -exec chmod 644 {} \+

	# polkit
	install -m 0644 ./share/polkit-1/actions/in.teejeetech.pkexec.timeshift.policy "$(DESTDIR)$(polkitdir)"

	# launcher
	install -m 0755 ${app_name}-gtk.desktop "$(DESTDIR)$(launcherdir)"

	# config
	install -m 0644 ../files/${app_name}.json "$(DESTDIR)$(appconfdir)/default.json"

	# man page
	install -m 0644 ../man/${app_name}.1.gz "$(DESTDIR)$(man1dir)/${app_name}.1.gz"

	# app icons
	cp -dpr --no-preserve=ownership -t "$(DESTDIR)$(sharedir)/icons" ./share/icons/*
	chmod --recursive 0644 $(DESTDIR)$(sharedir)/icons/hicolor/*/apps/${app_name}.png
	
	# app icon
	install -m 0755 ./share/pixmaps/${app_name}.png "$(DESTDIR)$(sharedir)/pixmaps/"
	
	# appdata
	#install -m 0644 ../debian/${app_name}.appdata.xml "$(DESTDIR)$(sharedir)/appdata" 
	install -m 0644 ../debian/${app_name}.appdata.xml "$(DESTDIR)$(sharedir)/metainfo"

	# translations
	for lang in am ar az bg ca cs da de el en_GB es et eu fi fr he hi hr hu ia id is it ja ko lt nb ne nl pl pt pt_BR ro ru sk sr sv tr uk vi zh_CN zh_TW; do \
		mkdir -p "$(DESTDIR)$(localedir)/$$lang/LC_MESSAGES"; \
		msgfmt --check --verbose -o "$(DESTDIR)$(localedir)/$$lang/LC_MESSAGES/${app_name}.mo" ../po/${app_name}-$$lang.po ; \
	done

uninstall:

	# binary
	rm -f "$(DESTDIR)$(bindir)/${app_name}"
	rm -f "$(DESTDIR)$(bindir)/${app_name}-gtk"
	rm -f "$(DESTDIR)$(bindir)/${app_name}-uninstall"
	rm -f "$(DESTDIR)$(bindir)/${app_name}-launcher"

	# shared files
	rm -rf "$(DESTDIR)$(sharedir)/${app_name}"

	# launcher
	rm -f "$(DESTDIR)$(launcherdir)/${app_name}-gtk.desktop"

	# polkit
	rm -f "$(DESTDIR)$(polkitdir)/in.teejeetech.pkexec.timeshift.policy"

	# man page
	rm -f "$(DESTDIR)$(man1dir)/${app_name}.1.gz"
	
	# app icon
	rm -f $(DESTDIR)$(sharedir)/icons/hicolor/*/apps/${app_name}.png

	# translations
	rm -f $(DESTDIR)$(localedir)/*/LC_MESSAGES/${app_name}.mo

	# appdata
	rm -f "$(DESTDIR)$(sharedir)/appdata/${app_name}.appdata.xml" 
	rm -f "$(DESTDIR)$(sharedir)/metainfo/${app_name}.appdata.xml"
