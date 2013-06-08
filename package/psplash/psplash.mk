################################################################################
#
# psplash
#
################################################################################

PSPLASH_VERSION = afd4e228c606a9998feae44a3fed4474803240b7
PSPLASH_SITE = http://git.yoctoproject.org/git/psplash
PSPLASH_SITE_METHOD = git
PSPLASH_AUTORECONF = YES
PSPLASH_CONF_OPT =
PSPLASH_DEPENDENCIES =

$(eval $(autotools-package))
