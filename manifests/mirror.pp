class apt::mirror(
    $base_path         = '/var/spool/apt-mirror',
    $mirror_path       = '$base_path/mirror',
    $skel_path         = '$base_path/skel',
    $var_path          = '$base_path/var',
    $cleanscript       = '$base_path/clean.sh',
    $postmirror_script = '$var_path/postmirror.sh',
    $defaultarch       = 'amd64',
    $run_postmirror    = '0',
    $nthreads          = '20',
    $_tilde            = '0',
  ) {
  package { 'apt-mirror':
    ensure => installed,
  }

  concat { '/etc/apt/mirror.list':
    owner   => 'root',
    group   => 0,
    mode    => '0664',
    require => Package['apt-mirror'],
  }


  concat::fragment { "apt-mirror-${name}.conf":
    target  => '/etc/apt/mirror.list',
    order   => '1',
    content => template('apt/mirror.list-base.erb'),
  }
}

define apt::mirror::source (
  $mirror_url          = 'UNDEF',
  $release           = 'UNDEF',
  $repos             = 'main',
  $include_src       = true,
  $architecture      = undef,
  $clean	     = true,
) {

  include apt::params
  if $release == 'UNDEF' {
    if $::lsbdistcodename == undef {
      fail('lsbdistcodename fact not available: release parameter required')
    } else {
      $release_real = $::lsbdistcodename
    }
  } else {
    $release_real = $release
  }
  if $mirror_url == 'UNDEF' {
    warning('No Valid mirror mirror_url setup')	
  } else {
    concat::fragment { "apt-mirror-${name}.conf":
      target  => '/etc/apt/mirror.list',
      order   => '50',
      content => template('apt/mirror.list-source.erb'),
    }
  }
}
