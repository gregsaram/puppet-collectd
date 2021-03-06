# See http://collectd.org/documentation/manpages/collectd.conf.5.shtml#plugin_curl_json
define collectd::plugin::curl_json (
  $url,
  $instance,
  $keys,
  $ensure         = 'present',
  $interval       = undef,
  $user           = undef,
  $password       = undef,
  $verifypeer     = undef,
  $verifyhost     = undef,
  $cacert         = undef,
  $header         = undef,
  $order          = '10',
  $manage_package = undef,
) {

  include ::collectd

  validate_hash($keys)

  $_manage_package = pick($manage_package, $::collectd::manage_package)

  if $_manage_package {
    if $::osfamily == 'Debian' {
      ensure_packages('libyajl2')
    }

    if $::osfamily == 'Redhat' {
      package { 'collectd-curl_json':
        ensure => $ensure,
      }
    }
  }

  $conf_dir = $collectd::plugin_conf_dir

  # This is deprecated file naming ensuring old style file removed, and should be removed in next major relese
  file { "${name}.load-deprecated":
    ensure => absent,
    path   => "${conf_dir}/${name}.conf",
  }
  # End deprecation

  file {
    "${name}.load":
      path    => "${conf_dir}/${order}-${name}.conf",
      owner   => 'root',
      group   => $collectd::root_group,
      mode    => '0640',
      content => template('collectd/curl_json.conf.erb'),
      notify  => Service['collectd'],
  }
}
