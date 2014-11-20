Vagrant.configure('2') do |config|
  config.vm.provider :digital_ocean do |provider, override|
    override.ssh.private_key_path = '~/.ssh/omoto_prd'
    override.vm.box = 'digital_ocean'
    override.vm.box_url = "https://github.com/smdahlen/vagrant-digitalocean/raw/master/box/digital_ocean.box"
    override.vm.hostname = 'omoto-mts'

    provider.ssh_key_name = "omoto-mac"
    provider.token = 'd69b08046c6b77350a3087340503d3554f0723deeb7444d44af25c624d7c630d'
    provider.image = '14.04 x64'
    provider.region = 'sgp1'
    provider.size = '512MB'

    config.vm.synced_folder ".", "/root/psync"
  end
end
