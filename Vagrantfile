Vagrant.configure(2) do |config|
  config.vm.box = 'ubuntu/xenial64'

  [ 8200 ].each do |port|
    config.vm.network 'forwarded_port', guest: 8200, host: 8200
  end

  config.vm.provision 'shell', inline: <<-SHELL
    set -e
    apt-get remove docker docker-engine
    apt-get update -qq

    # Install Docker
    apt-get install -q -y apt-transport-https ca-certificates curl linux-image-extra-$(uname -r) linux-image-extra-virtual software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    apt-get update -qq
    apt-get install -q -y docker-ce

    # Install Docker Compose
    curl -L "https://github.com/docker/compose/releases/download/1.13.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose

    # Print versions
    docker --version
    docker-compose --version

    # Start containers
    cd /vagrant
    docker-compose up --build -d
  SHELL
end
