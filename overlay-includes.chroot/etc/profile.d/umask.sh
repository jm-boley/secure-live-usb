# Set default file/directory permissions for new files
# umask works by SUBTRACTING permissions from the default (666 for files, 777 for directories)
#
# umask 027 means:
# 0 - No changes to owner permissions (full read/write/execute)
# 2 - Remove write from group permissions (has read/execute only)
# 7 - Remove all permissions from others (no access)
#
# This provides a good balance between security and collaboration:
# - Owner maintains full control
# - Group members can read/execute but not modify
# - Others have no access for improved security
umask 027
