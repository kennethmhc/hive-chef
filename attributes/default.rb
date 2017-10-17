include_attribute "kagent"
include_attribute "ndb"
include_attribute "hops"
include_attribute "kzookeeper"

default['hive2']['user']                    = node['install']['user'].empty? ? "hive" : node['install']['user']
default['hive2']['group']                   = node['install']['user'].empty? ? node['hops']['group'] : node['install']['user']
default['hive2']['version']                 = "2.3.0"
default['hive2']['url']                     = "#{node['download_url']}/apache-hive-#{node['hive2']['version']}-bin.tar.gz"
default['hive2']['port']                    = "9084"
default['hive2']['portssl']                 = "9085"
default['hive2']['dir']                     = node['install']['dir'].empty? ? "/srv" : node['install']['dir']
default['hive2']['home']                    = node['hive2']['dir'] + "/apache-hive-" + node['hive2']['version'] + "-bin"
default['hive2']['base_dir']                = node['hive2']['dir'] + "/apache-hive"
default['hive2']['logs_dir']                = node['hive2']['base_dir'] + "/logs"
default['hive2']['hopsfs_dir']              = "/apps/hive"
default['hive2']['scratch_dir']             = "/tmp/hive"
default['hive2']['keystore']                = "#{node['kagent']['base_dir']}/node_server_keystore.jks"
default['hive2']['keystore_password']       = "changeit"

default['hive2']['mysql_user']              = "hive"
default['hive2']['mysql_password']          = "hive"

default['hive2']['metastore']['port']       = "9083"
default['hive2']['systemd']                 = "true"

default['hive2']['hopsworks']['port']         = "8080"

default['hive2']['hive_cleaner']['version']   = "0.1.2"
default['hive2']['hive_cleaner']['url']       = "#{node['download_url']}/hivecleaner/#{node['platform']}/hivecleaner-#{node['hive2']['hive_cleaner']['version']}.tar.gz"

default['tez']['user']                    =  node['install']['user'].empty? ? "tez" : node['install']['user']
default['tez']['group']                   =  node['hops']['group']
default['tez']['version']                 = "0.8.5"
default['tez']['url']                     = "#{node['download_url']}/apache-tez-#{node['tez']['version']}.tar.gz"
default['tez']['dir']                     =  node['install']['dir'].empty? ? "/srv" : node['install']['dir']
default['tez']['home']                    =  node['tez']['dir'] + "/apache-tez-" + node['tez']['version']
default['tez']['base_dir']                =  node['tez']['dir'] + "/apache-tez"
default['tez']['hopsfs_dir']              = "/apps/tez"
default['tez']['conf_dir']                =  node['tez']['base_dir'] + "/conf"

#default.hive2.metastore.public_ips                   = ['']
#default.hive2.metastore.private_ips                  = ['']
#default.hive2.server2.public_ips                     = ['']
#default.hive2.server2.private_ips                    = ['']
#default.hive2['default']['public_ips']               = ['']
#default.hive2['default']['private_ips']              = ['']
