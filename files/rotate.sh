#!/bin/bash

# Dry run
dry=0

rotation=$1
keep_count=$2
destination=$3
name=$4 # ${name}-2013-10-02.(tar.gz|sql.gz)

dir=${destination}/${rotation}
# Match pattern for filename-yyyy-mm-dd.extension files.
find_pattern="${name}-[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9].*"

remove_older() {
  local max_age=$2
  local delete="$(find $dir -maxdepth 1 -name "$find_pattern" -mtime +$max_age)"

  while IFS= read -d $'\n' -r file; do
    if ((dry)); then
      echo "rm -v '$file'"
    else
      rm -v "$file"
    fi
  done <<< "$delete"
}

backup_exists() {
  if [[ $(find $dir -maxdepth 1 -name "$find_pattern" -mtime -$max_age | wc -l) -gt 0 ]]; then
    return 1
  fi
}

# Figure out the maximum age of a valid file depending on the rotation type
case $rotation in
  daily)    days=1    ;;
  weekly)   days=7    ;;
  monthly)  days=31   ;;
  yearly)   days=365  ;;
  *)        echo "Unkown rotation $rotation"; exit 1;
esac

# The maximum age of a valid backup, older than this is removed.
max_age=$(expr $((($keep_count * $days) + 1)))

# Delete expired backups
remove_older "$max_age"

# If a backup already exists for this rotation return success
if backup_exists "$days"; then
  exit 0
fi
# If a backup is necessary, exit with a unqiue exit code
exit 3
