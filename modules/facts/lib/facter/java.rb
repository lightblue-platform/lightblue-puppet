require 'facter'

# For non-Linux nodes
Facter.add(:find_exports_location) do
    setcode do
        nil
    end
end

# For Linux
Facter.add(:find_exports_location) do
    confine :kernel  => :linux
    setcode do
        Facter::Util::Resolution.exec("/usr/bin/find /usr/lib/jvm-exports/ -name $(cat /tmp/java_version)*")
    end
end
