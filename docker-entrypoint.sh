#!/bin/bash
set -e

if [ -z "$MYSQL_PORT_3306_TCP" ]; then
	echo >&2 'error: missing MYSQL_PORT_3306_TCP environment variable'
	echo >&2 '  Did you forget to --link some_mysql_container:mysql ?'
	exit 1
fi

# if we're linked to MySQL, and we're using the root user, and our linked
# container has a default "root" password set up and passed through... :)
: ${IMPRESSPAGES_DB_USER:=root}
if [ "$IMPRESSPAGES_DB_USER" = 'root' ]; then
	: ${IMPRESSPAGES_DB_PASSWORD:=$MYSQL_ENV_MYSQL_ROOT_PASSWORD}
fi
: ${IMPRESSPAGES_DB_NAME:=impresspages}

if [ -z "$IMPRESSPAGES_DB_PASSWORD" ]; then
	echo >&2 'error: missing required IMPRESSPAGES_DB_PASSWORD environment variable'
	echo >&2 '  Did you forget to -e IMPRESSPAGES_DB_PASSWORD=... ?'
	echo >&2
	echo >&2 '  (Also of interest might be IMPRESSPAGES_DB_USER and IMPRESSPAGES_DB_NAME.)'
	exit 1
fi

if ! [ -e index.php -a -e Lp/Application.php ]; then
	echo >&2 "ImpressPages not found in $(pwd) - copying now..."
	if [ "$(ls -A)" ]; then
		echo >&2 "WARNING: $(pwd) is not empty - press Ctrl+C now if this is an error!"
		( set -x; ls -A; sleep 10 )
	fi
	rsync --archive --one-file-system --quiet /usr/src/ImpressPages/ ./
	echo >&2 "Complete! ImpressPages has been successfully copied to $(pwd)"
	if [ ! -e .htaccess ]; then
		cat > .htaccess <<-'EOF'
			RewriteEngine On
			RewriteBase /
			RewriteRule ^index\.php$ - [L]
			RewriteCond %{REQUEST_FILENAME} !-f
			RewriteCond %{REQUEST_FILENAME} !-d
			RewriteRule . /index.php [L]
		EOF
	fi
fi


set_config() {
	key="$1"
	value="$2"
	php_escaped_value="$(php -r 'var_export($argv[1]);' "$value")"
	sed_escaped_value="$(echo "$php_escaped_value" | sed 's/[\/&]/\\&/g'),"
	sed -ri "0,/((['\"])$key\2\s*=>\s*)(['\"])\S*\3,/s//\1$sed_escaped_value/" install/Plugin/Install/PublicController.php
}


IMPRESSPAGES_DB_HOST="${MYSQL_PORT_3306_TCP#tcp://}"

set_config 'hostname' "$IMPRESSPAGES_DB_HOST"
set_config 'username' "$IMPRESSPAGES_DB_USER"
set_config 'password' "$IMPRESSPAGES_DB_PASSWORD"
set_config 'database' "$IMPRESSPAGES_DB_NAME"

chown -R www-data:www-data .

exec "$@"