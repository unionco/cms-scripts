# Common scripts for healthy CMS servers

## Files

`cron.sh`

```
Usage: ./cron.sh [OPTS] -d SITE_DIR
Options:
        -p PHP_BIN      path to PHP executable
        -o OWNER        user:group for cms directories
        -s              clear storage
        -c              clear cache
        -q              run the queue
        -d SITE_DIR     path to CMS base directory
```

### Examples - cron.sh

#### Example 1 - Permissions and Queue
(as a cronjob, every minute) - `*/1 * * * *`
```
bash cron.sh \
    -p /usr/local/bin/php \     # Set the PHP binary to use
    -d /var/www/current/cms \   # Set the CMS root
    -o ubuntu:www-data \        # Set ownership for writable directories to this user:group
    -q                          # Run the queue
```

#### Example 2
(as a cronjob, every night at 1 AM) - `0 1 * * *`
```
bash cron.sh \
    -p /usr/local/bin/php \ # Set the PHP binary to use
    -s \                    # Clear out the {BASE}/storage directory
    -c \                    # Clear all Craft-managed caches
    -d /var/www/current/cms # Set the CMS root
```


