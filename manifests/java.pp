# This module will properly configure the java JVM and SDK on a Linux machine
# that support the /etc/alternatives configuration abstraction.  This will also
# provide the JAVA_HOME environment variable for Java based projects that only
# support the environment style configuration.
# Note: the alternatives entries for java is made by the company who package the RPM, such as http://pkgs.fedoraproject.org/cgit/java-1.7.0-openjdk.git/tree/java-1.7.0-openjdk.spec?h=f17 for openjdk7 and http://pkgs.fedoraproject.org/cgit/java-1.8.0-openjdk.git/tree/java-1.8.0-openjdk.spec for openjdk8 (which can be useful for insights for this class)
include stdlib

class lightblue::java ($java_version = '1.7.0', $java_distribution = 'openjdk') {

  $java_jre_location = $::architecture ? {
    'i386'   => "/usr/lib/jvm/jre-${java_version}-${java_distribution}/bin/java",
    'x86_64' => "/usr/lib/jvm/jre-${java_version}-${java_distribution}.${::architecture}/bin/java"
  }
  $java_sdk_location = $::architecture ? {
    'i386'   => "/usr/lib/jvm/java-${java_version}-${java_distribution}",
    'x86_64' => "/usr/lib/jvm/java-${java_version}-${java_distribution}.${::architecture}"
  }
  $java_home = "/etc/alternatives/java_sdk_${java_distribution}"
  $java_version_distribution = $::architecture ? {
    'i386'   => "${java_version}-${java_distribution}",
    'x86_64' => "${java_version}-${java_distribution}.${::architecture}"
  }
  $jvm_dir = "/usr/lib/jvm/"
  $jvm_export = "/usr/lib/jvm-exports/"
  $jre_location = "${jvm_dir}jre-${java_version_distribution}"
  $alternative_priority = 9000000
  $exports_location = $::find_exports_location # This statement should be after the java installation but puppet doesnt allow
  
  anchor { 'lightblue::java::begin:': }
  ->
  package { 'java':
    ensure => [installed,$java_version],
    name   => "java-${java_version}-${java_distribution}",
  }
  ->
  package { 'java-devel':
    ensure => [installed,$java_version],
    name   => "java-${java_version}-${java_distribution}-devel",
  }
  ->
  file { '/etc/profile.d/java-env.sh':
    mode    => '0755',
    content => inline_template('export JAVA_HOME=<%= java_home %>'),
  }
  ->
  exec { "create temporary file with java version":
    path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] ,
    command =>   "echo java-${java_version}-${java_distribution} > /tmp/java_version",
    require => [File['/etc/profile.d/java-env.sh'],Package['java-devel']],
  }
#  ->  $exports_location = $::find_exports_location #puppet doesn allow this statement here

  ->
#jre section - begin
  exec { "install jre_${java_version}":
    path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] ,
    command =>   "alternatives \
        --install ${jvm_dir}/jre-${java_version} \
        jre_${java_version} ${jre_location} ${alternative_priority} \
        --slave ${jvm_export}/jre-${java_version} \
        jre_${java_version}_exports ${exports_location} ",
    require => [File['/etc/profile.d/java-env.sh'],Package['java-devel']],
    unless => "alternatives --display jre_${java_version} > /dev/null",
  }
  ->
  exec { "configure jre_${java_version}":
    path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] ,
    command => "/usr/sbin/alternatives --set jre_${java_version} '${jre_location}'",
    require => [File['/etc/profile.d/java-env.sh'],Package['java-devel']],
    unless => "test /etc/alternatives/jre_${java_version} -ef ${jre_location} && /usr/sbin/alternatives --display jre_${java_version} | grep link | grep ${jre_location}",
  }
  ->
  exec { "install jre_${java_distribution}":
    path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] ,
    command =>   "alternatives \
        --install ${jvm_dir}/jre-${java_distribution} \
        jre_${java_distribution} ${jre_location} ${alternative_priority} \
        --slave ${jvm_export}/jre-${java_distribution} \
        jre_${java_distribution}_exports ${exports_location} ",
    require => [File['/etc/profile.d/java-env.sh'],Package['java-devel']],
    unless => "alternatives --display jre_${java_distribution} > /dev/null",
  }
  ->
  exec { "configure jre_${java_distribution}":
    path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] ,
    command => "/usr/sbin/alternatives --set jre_${java_distribution} '${jre_location}'",
    require => [File['/etc/profile.d/java-env.sh'],Package['java-devel']],
    unless => "test /etc/alternatives/jre_${java_distribution} -ef ${jre_location} && /usr/sbin/alternatives --display jre_${java_distribution} | grep link | grep ${jre_location}",
  }
  ->
  exec { "install jre_${java_version}_${java_distribution}":
    path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] ,
    command =>   "alternatives \
        --install ${jvm_dir}/jre-${java_version}-${java_distribution} \
        jre_${java_version}_${java_distribution} ${jre_location} ${alternative_priority} \
        --slave ${jvm_export}/jre-${java_version}-${java_distribution} \
        jre_${java_version}_${java_distribution}_exports ${exports_location} ",
    require => [File['/etc/profile.d/java-env.sh'],Package['java-devel']],
    unless => "alternatives --display jre_${java_version}_${java_distribution} > /dev/null",
  }
  ->
  exec { "configure jre_${java_version}_${java_distribution}":
    path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] ,
    command => "/usr/sbin/alternatives --set jre_${java_version}_${java_distribution} '${jre_location}'",
    require => [File['/etc/profile.d/java-env.sh'],Package['java-devel']],
    unless => "test /etc/alternatives/jre_${java_version}_${java_distribution} -ef ${jre_location} && /usr/sbin/alternatives --display jre_${java_version}_${java_distribution} | grep link | grep ${jre_location}",
  }
#jre section - end
  ->
#sdk section - begin
  exec { "install java_sdk_${java_version}":
    path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] ,
    command =>   "alternatives \
        --install ${jvm_dir}/java-${java_version} \
        java_sdk_${java_version} ${java_sdk_location} ${alternative_priority} \
        --slave ${jvm_export}/java-${java_version} \
        java_sdk_${java_version}_exports ${exports_location} ",
    require => [File['/etc/profile.d/java-env.sh'],Package['java-devel']],
    unless => "alternatives --display java_sdk_${java_version} > /dev/null",
  }
  ->
  exec { "configure java_sdk_${java_version}":
    path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] ,
    command => "/usr/sbin/alternatives --set java_sdk_${java_version} '${java_sdk_location}'",
    require => [File['/etc/profile.d/java-env.sh'],Package['java-devel']],
    unless => "test /etc/alternatives/java_sdk_${java_version} -ef ${java_sdk_location} && /usr/sbin/alternatives --display java_sdk_${java_version} | grep link | grep ${java_sdk_location}",
  }
  ->
  exec { "install java_sdk_${java_distribution}":
    path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] ,
    command =>   "alternatives \
        --install ${jvm_dir}/java-${java_distribution} \
        java_sdk_${java_distribution} ${java_sdk_location} ${alternative_priority} \
        --slave ${jvm_export}/java-${java_distribution} \
        java_sdk_${java_distribution}_exports ${exports_location} ",
    require => [File['/etc/profile.d/java-env.sh'],Package['java-devel']],
    unless => "alternatives --display java_sdk_${java_distribution} > /dev/null",
  }
  ->
  exec { "configure java_sdk_${java_distribution}":
    path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] ,
    command => "/usr/sbin/alternatives --set java_sdk_${java_distribution} '${java_sdk_location}'",
    require => [File['/etc/profile.d/java-env.sh'],Package['java-devel']],
    unless => "test /etc/alternatives/java_sdk_${java_distribution} -ef ${java_sdk_location} && /usr/sbin/alternatives --display java_sdk_${java_distribution} | grep link | grep ${java_sdk_location}",
  }
  ->
  exec { "install java_sdk_${java_version}_${java_distribution}":
    path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] ,
    command =>   "alternatives \
        --install ${jvm_dir}/java-${java_version}-${java_distribution} \
        java_sdk_${java_version}_${java_distribution} ${java_sdk_location} ${alternative_priority} \
        --slave ${jvm_export}/java-${java_version}-${java_distribution} \
        java_sdk_${java_distribution}_exports ${exports_location} ",
    require => [File['/etc/profile.d/java-env.sh'],Package['java-devel']],
    unless => "alternatives --display java_sdk_${java_version}_${java_distribution} > /dev/null",
  }
  ->
  exec { "configure java_sdk_${java_version}_${java_distribution}":
    path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] ,
    command => "/usr/sbin/alternatives --set java_sdk_${java_version}_${java_distribution} '${java_sdk_location}'",
    require => [File['/etc/profile.d/java-env.sh'],Package['java-devel']],
    unless => "test /etc/alternatives/java_sdk_${java_version}_${java_distribution} -ef ${java_sdk_location} && /usr/sbin/alternatives --display java_sdk_${java_version}_${java_distribution} | grep link | grep ${java_sdk_location}",
  }
#sdk section - end
  ->
#java section - begin
  exec { "install java":
    path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] ,
    command =>   "alternatives \
        --install /usr/bin/java java ${java_jre_location} ${alternative_priority} \
        --slave ${jvm_dir}/jre jre ${jre_location} \
        --slave ${jvm_export}/jre jre_exports ${exports_location} \
        --slave /usr/bin/keytool keytool ${jre_location}/bin/keytool \
        --slave /usr/bin/orbd orbd ${jre_location}/bin/orbd \
        --slave /usr/bin/pack200 pack200 ${jre_location}/bin/pack200 \
        --slave /usr/bin/rmid rmid ${jre_location}/bin/rmid \
        --slave /usr/bin/rmiregistry rmiregistry ${jre_location}/bin/rmiregistry \
        --slave /usr/bin/servertool servertool ${jre_location}/bin/servertool \
        --slave /usr/bin/tnameserv tnameserv ${jre_location}/bin/tnameserv \
        --slave /usr/bin/unpack200 unpack200 ${jre_location}/bin/unpack200",
    require => [File['/etc/profile.d/java-env.sh'],Package['java-devel']],
    unless => "alternatives --display java_sdk_${java_version}_${java_distribution} > /dev/null",
  }
  ->
  exec { 'configure java':
    path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] ,
    command => "/usr/sbin/alternatives --set java '${java_jre_location}'",
    require => [File['/etc/profile.d/java-env.sh'],Package['java']],
    unless => "test /etc/alternatives/java -ef ${java_jre_location} && /usr/sbin/alternatives --display java | grep link | grep ${java_jre_location}",
  }
#java section - end
  ->
#javac section - begin
  exec { "install javac":
    path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] ,
    command =>   "alternatives \
  --install /usr/bin/javac javac ${java_sdk_location}/bin/javac ${alternative_priority} \
  --slave ${jvm_dir}/java java_sdk ${java_sdk_location} \
  --slave ${jvm_export}/java java_sdk_exports ${exports_location}  \
  --slave /usr/bin/appletviewer appletviewer ${java_sdk_location}/bin/appletviewer \
  --slave /usr/bin/apt apt ${java_sdk_location}/bin/apt \
  --slave /usr/bin/extcheck extcheck ${java_sdk_location}/bin/extcheck \
  --slave /usr/bin/idlj idlj ${java_sdk_location}/bin/idlj \
  --slave /usr/bin/jar jar ${java_sdk_location}/bin/jar \
  --slave /usr/bin/jarsigner jarsigner ${java_sdk_location}/bin/jarsigner \
  --slave /usr/bin/javadoc javadoc ${java_sdk_location}/bin/javadoc \
  --slave /usr/bin/javah javah ${java_sdk_location}/bin/javah \
  --slave /usr/bin/javap javap ${java_sdk_location}/bin/javap \
  --slave /usr/bin/jcmd jcmd ${java_sdk_location}/bin/jcmd \
  --slave /usr/bin/jconsole jconsole ${java_sdk_location}/bin/jconsole \
  --slave /usr/bin/jdb jdb ${java_sdk_location}/bin/jdb \
  --slave /usr/bin/jhat jhat ${java_sdk_location}/bin/jhat \
  --slave /usr/bin/jinfo jinfo ${java_sdk_location}/bin/jinfo \
  --slave /usr/bin/jmap jmap ${java_sdk_location}/bin/jmap \
  --slave /usr/bin/jps jps ${java_sdk_location}/bin/jps \
  --slave /usr/bin/jrunscript jrunscript ${java_sdk_location}/bin/jrunscript \
  --slave /usr/bin/jsadebugd jsadebugd ${java_sdk_location}/bin/jsadebugd \
  --slave /usr/bin/jstack jstack ${java_sdk_location}/bin/jstack \
  --slave /usr/bin/jstat jstat ${java_sdk_location}/bin/jstat \
  --slave /usr/bin/jstatd jstatd ${java_sdk_location}/bin/jstatd \
  --slave /usr/bin/native2ascii native2ascii ${java_sdk_location}/bin/native2ascii \
  --slave /usr/bin/policytool policytool ${java_sdk_location}/bin/policytool \
  --slave /usr/bin/rmic rmic ${java_sdk_location}/bin/rmic \
  --slave /usr/bin/schemagen schemagen ${java_sdk_location}/bin/schemagen \
  --slave /usr/bin/serialver serialver ${java_sdk_location}/bin/serialver \
  --slave /usr/bin/wsgen wsgen ${java_sdk_location}/bin/wsgen \
  --slave /usr/bin/wsimport wsimport ${java_sdk_location}/bin/wsimport \
  --slave /usr/bin/xjc xjc ${java_sdk_location}/bin/xjc",
    require => [File['/etc/profile.d/java-env.sh'],Package['java-devel']],
    unless => "alternatives --display java_sdk_${java_version}_${java_distribution} > /dev/null",
  }
  ->
  exec { 'configure javac':
    path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] ,
    command => "/usr/sbin/alternatives --set javac '${java_sdk_location}/bin/javac'",
    require => [File['/etc/profile.d/java-env.sh'],Package['java-devel']],
    unless => "test /etc/alternatives/javac -ef ${java_sdk_location}/bin/javac && /usr/sbin/alternatives --display javac | grep link | grep ${java_sdk_location}/bin/javac",
  }
#javac section - end
  ->
  anchor { 'lightblue::java::end': }
}
