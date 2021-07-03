## 1.0.0 - rc3-210703

**DFiles**
* Basic features are implement
* Command-line options and server support
* Environment options and docker support
* Restful API support: /start, /stop, /timer/(seconds), /days/(days), /count/(files), /printAll/(true/false)
* Documentation

**Environment Options**
* API port : DFILES_PORT=8086
* Monitoring path : DFILES_MONITOR=/app/monitor
* Include sub path : DFILES_MONITOR_RECURSIVE=false
* Count in a path : DFILES_COUNT=5 [disable=0]
* Modified date in days : DFILES_DAYS=10 [disable=0]
* Timer (seconds) : DFILES_TIMER=3 [once=0]
* Print detailed log : DFILES_PRINT_ALL=true

**Fixed**
* fixed to delete files and directories something wrong
* fixed to support these default values for count, days and timer
* fixed to monitor path /app/monitor instead of /app/dcache/monitor

## 1.0.0 - baseline0-201112

* Initial version, created by ilshookim
