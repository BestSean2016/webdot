#!/bin/sh
# Run this to generate all the initial makefiles, etc.

WEBDOT_VERSION_DATE=$( git log -n 1 --format=%ct )
if test $? -eq 0; then
    WEBDOT_VERSION_DATE=$( date -u +%Y%m%d.%H%M -d @$WEBDOT_VERSION_DATE )
    echo "Version date is based on time of last commit: $WEBDOT_VERSION_DATE"
else
    WEBDOT_VERSION_DATE="0"
    echo "Warning: we do not appear to be running in a git clone." >&2
fi

# initialize version for a "stable" build
cat >./version.m4 <<EOF
dnl webdot package version number, (as distinct from shared library version)
dnl For the minor number: odd => unstable series
dnl                       even => stable series
dnl For the micro number: 0 => in-progress development
dnl                       timestamp => tar-file snapshot or release
m4_define(webdot_version_major, 2)
m4_define(webdot_version_minor, 39)
dnl NB: the next line gets changed to a date/time string for development releases
m4_define(webdot_version_micro, $WEBDOT_VERSION_DATE)
m4_define(webdot_version_date, $WEBDOT_VERSION_DATE)
m4_define(webdot_collection, test)
m4_define(webdot_version_commit, unknown)
EOF

autoreconf -v --install --force || exit 1

# ensure config/depcomp exists even if still using automake-1.4
# otherwise "make dist" fails.
touch config/depcomp

# suppress automatic ./configure  is "./autogen.sh NOCONFIG"
if test "$1" != "NOCONFIG"; then
    # don't use any old cache, but create a new one
    rm -f config.cache
    ./configure -C "$@"
fi

