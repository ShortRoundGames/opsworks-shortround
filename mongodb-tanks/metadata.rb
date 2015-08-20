name              "mongodb-tanks"
maintainer        "ShortRound Games"
maintainer_email  "kim@shortroundgames.com"
license           "Apache 2.0"
description       "Installs/configures mongodb for Tanks"
version           "0.1.0"

recipe "10gen_repo", "Adds the 10gen repo to get the latest packages"

depends "apt", ">= 1.8.2"
depends "runit"
depends "yum"

%w{ ubuntu debian freebsd centos redhat fedora amazon scientific}.each do |os|
  supports os
end
