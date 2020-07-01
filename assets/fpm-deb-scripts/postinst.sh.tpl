#!/bin/sh
after_upgrade() {
  echo "Upgrading from $@"
}

after_install() {
  echo "Installing ${GH_RELEASE}" data...
  curl -sL https://github.com/StuartApp/libpostal/releases/download/${GH_RELEASE}/libpostal_${GH_RELEASE}.tar.gz
}

export GH_RELEASE=${DEB_PACKAGE_VERSION}

if [ "${1}" = "configure" -a -z "${2}" ] || \
   [ "${1}" = "abort-remove" ]
then
    # "after install" here
    # "abort-remove" happens when the pre-removal script failed.
    #   In that case, this script, which should be idemptoent, is run
    #   to ensure a clean roll-back of the removal.
    installingVersion="${2}"
    after_install 
elif [ "${1}" = "configure" -a -n "${2}" ]
then
    upgradeFromVersion="${2}"
    # "after upgrade" here
    # NOTE: This slot is also used when deb packages are removed,
    # but their config files aren't, but a newer version of the
    # package is installed later, called "Config-Files" state.
    # basically, that still looks a _lot_ like an upgrade to me.
    after_upgrade "${2}"
elif echo "${1}" | grep -E -q "(abort|fail)"
then
    echo "Failed to install before the post-installation script was run." >&2
    exit 1
fi
