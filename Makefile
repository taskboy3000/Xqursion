check:
	find lib -name '*.pm' -exec 'perl' '-wc' '{}' ';'
clean:
	find . -name '*~' -exec 'rm' '-f' '{}' ';'
