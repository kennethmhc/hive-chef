include_recipe "java"

my_ip = my_private_ip()

group node.hive2.group do
  action :create
  not_if "getent group #{node.hive2.group}"
end

user node.hive2.user do
  home "/home/#{node.hive2.user}"
  action :create
  shell "/bin/bash"
  manage_home true
  not_if "getent passwd #{node.hive2.user}"
end

group node.hive2.group do
  action :modify
  members ["#{node.hive2.user}"]
  append true
end


package_url = "#{node.hive2.url}"
base_package_filename = File.basename(package_url)
cached_package_filename = "/tmp/#{base_package_filename}"

remote_file cached_package_filename do
  source package_url
  owner "#{node.hive2.user}"
  mode "0644"
  action :create_if_missing
end

# Extract Hive
hive_downloaded = "#{node.hive2.home}/.hive_extracted_#{node.hive2.version}"

bash 'extract-hive' do
        user "root"
        group node.hive2.group
        code <<-EOH
                set -e
                tar zxf #{cached_package_filename} -C /tmp
                mv /tmp/apache-hive-#{node.hive2.version}-bin #{node.hive2.dir}
                # remove old symbolic link, if any
                rm -f #{node.hive2.base_dir}
                ln -s #{node.hive2.home} #{node.hive2.base_dir}
                chown -R #{node.hive2.user}:#{node.hive2.group} #{node.hive2.home}
                chown -R #{node.hive2.user}:#{node.hive2.group} #{node.hive2.base_dir}
                touch #{hive_downloaded}
                chown -R #{node.hive2.user}:#{node.hive2.group} #{hive_downloaded}
        EOH
     not_if { ::File.exists?( "#{hive_downloaded}" ) }
end

# Download and extract hive_cleaner
# Install lihbdfs3 dependencies
case node[:platform]
when 'centos'
  bash 'install-dep' do
    user 'root'
    group 'root'
    code <<-EOH
        yum install -y epel-release
        curl -L \"https://bintray.com/wangzw/rpm/rpm\" -o /etc/yum.repos.d/bintray-wangzw-rpm.repo
        yum makecache
        yum install -y libhdfs3 libhdfs3-devel
    EOH
  end
when 'ubuntu'
   apt_package ['libc6', 'libgcc1', 'libgsasl7', 'libkrb5-3',
                'libstdc++6', 'libuuid1', 'libxml2']

  # Download libhdfs3
  package_url = "#{node.hive2.hive_cleaner.libhdfs3}"
  base_package_filename = File.basename(package_url)
  cached_package_filename = "/tmp/#{base_package_filename}"

  remote_file cached_package_filename do
    source package_url
    owner 'root'
    group 'root'
    mode "0644"
    action :create_if_missing
  end

  libhdfs3_downloaded = "#{node.hive2.home}/.libhdfs3"

  bash 'extract-libhdfs3' do
          user 'root'
          group 'root'
          code <<-EOH
                  set -e
                  tar zxf #{cached_package_filename} -C /tmp
                  mv /tmp/libhdfs3/lib/* /usr/local/lib
                  touch #{libhdfs3_downloaded}
          EOH
      not_if { ::File.exists?( "#{libhdfs3_downloaded}" ) }
  end
end

# Download Hive cleaner
package_url = "#{node.hive2.hive_cleaner.url}"
base_package_filename = File.basename(package_url)
cached_package_filename = "/tmp/#{base_package_filename}"

remote_file cached_package_filename do
  source package_url
  owner node.hops.hdfs.user
  group node.hops.group
  mode "0644"
  action :create_if_missing
end

cleaner_downloaded = "#{node.hive2.home}/.cleaner_extracted_#{node.hive2.hive_cleaner.version}"

bash 'extract-cleaner' do
        user node.hops.hdfs.user
        group node.hops.group
        code <<-EOH
                set -e
                tar zxf #{cached_package_filename} -C /tmp
                mv /tmp/hivecleaner-#{node.hive2.hive_cleaner.version}/hive_cleaner #{node.hive2.base_dir}/bin/
                touch #{cleaner_downloaded}
        EOH
     not_if { ::File.exists?( "#{cleaner_downloaded}" ) }
end

#Add the wiper
file "#{node.hive2.base_dir}/bin/wiper.sh" do
  action :delete
end

template "#{node.hive2.base_dir}/bin/wiper.sh" do
  source "wiper.sh.erb"
  owner node.hops.hdfs.user
  group node.hops.group
  mode 0755
end
