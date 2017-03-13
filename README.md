# Docker for Mac Workarounds

## Flush Fix

The old disk/full-sync-on-flush is now replaced by the key disk/on-flush which takes the following values:
- os: use fsync to flush the buffers to the OS
- drive: use fcntl to flush the buffers to the drive
- none: do nothing on a flush

### Usage
```
./flush-fix.sh -v -f none
```

### Options
```
./flush-fix.sh [options...]

  Options:
  -f [value]  Supported value's in preferred order:
              - none (do nothing on a flush)
              - ︎os (use fsync to flush the buffers to the OS)
              - drive (use fcntl to flush the buffers to the drive)
  -v          Verbose output
  -h          Show this help
```