class phpipam (
  $db_host       = 'localhost',
  $db_name       = 'phpipam',
  $db_pass       = 'phpipamadmin',
  $db_user       = 'phpipam',
  $docroot       = 'USE_DEFAULTS',
  $enable_debug  = false,
  $http_base     = '/phpipam/',
  $package_name  = 'USE_DEFAULTS',
  $phpsessname   = 'phpipam',
  $servername    = undef,
) {

  case $::operatingsystem {
    'Debian': {
      $default_package_name = 'phpipam'
      $default_docroot = '/usr/share/phpipam'
    }
    default: {
      fail("Unsupported operatingsystem \"$::operatingsystem\"")
    }
  }

  validate_string($db_host)
  validate_string($db_name)
  validate_string($db_pass)
  validate_string($db_user)

  if $docroot == 'USE_DEFAULTS' {
    $docroot_real = $default_docroot
  } else {
    $docroot_real = $docroot
  }

  if is_string($enable_debug) {
    $enable_debug_real = str2bool($enable_debug)
  } else {
    $enable_debug_real = $enable_debug
  }
  validate_bool($enable_debug_real)

  validate_string($http_base)

  if $package_name == "USE_DEFAULTS" {
    $package_name_real = $default_package_name
  } else {
    $package_name_real = $package_name
  }
  validate_string($package_name)

  validate_string($phpsessname)

  package { "$package_name_real":
    ensure => installed,
  }

  file { "/etc/phpipam.conf":
    ensure   => 'file',
    owner    => 'www-data',
    group    => 'www-data',
    content  => template('phpipam/phpipam.conf.erb'),
    require  => Package[$package_name_real],
  }

  file { "/usr/share/phpipam/.htaccess":
    ensure   => 'file',
    owner    => 'www-data',
    group    => 'www-data',
    content  => template('phpipam/htaccess.erb'),
    require  => Package[$package_name_real],
  }

  if $servername != undef {
    validate_string($servername)

    apache::vhost { "$servername":
      docroot     => $docroot_real,
      servername  => $servername,
      port        => '80',
    }
  }
}
