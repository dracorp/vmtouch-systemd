DESTDIR=
PREFIX=/usr
SYSCONFDIR=/etc

all:

install:
	install -Dm755 vmtouch.sh $(DESTDIR)$(PREFIX)/lib/systemd/scripts/vmtouch
	install -Dm644 vmtouch.service $(DESTDIR)$(PREFIX)/lib/systemd/system/vmtouch.service
	install -Dm644 vmtouch.default $(DESTDIR)$(SYSCONFDIR)/default/vmtouch
	install -Dm644 vmtouch.conf $(DESTDIR)$(SYSCONFDIR)/vmtouch.conf

uninstall:
	rm $(DESTDIR)$(PREFIX)/lib/systemd/scripts/vmtouch
	rm $(DESTDIR)$(PREFIX)/lib/systemd/system/vmtouch.service
	rm $(DESTDIR)$(SYSCONFDIR)/default/vmtouch
	rm $(DESTDIR)$(SYSCONFDIR)/vmtouch.conf
