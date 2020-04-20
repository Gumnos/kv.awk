all:
	@echo run 'sudo make install' to install the script and completion
	@echo run 'sudo make remove'  to uninstall them.

install:
	cp -f kv.awk /usr/local/bin/
	chmod +x /usr/local/bin/kv.awk
	cp -f kv.awk-completion.bash /etc/bash_completion.d/kv.awk

remove:
	rm -f /usr/local/bin/kv.awk
	rm -f /etc/bash_completion.d/kv.awk
