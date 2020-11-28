#!/bin/sh

# This script will initialize a new LXD container
# with GitLab Runner within 2 minutes.

#Author    :Karel Fiala
#Email     :fiala.karel@gmail.com
#Version   :v1.0.0
#Date      :20201128
#Usage     :wget -q https://raw.githubusercontent.com/fialakarel/scripts/master/gitlab/lxc-launch-gitlab-runner.sh -O - | bash -

set -ef

log() {
    echo "[lxc-launch-gitlab-runner.sh] ${*}"
}

log 'Please, provide GitLab Runner token (NOT REGISTRATION TOKEN)'
read GITLAB_RUNNER_TOKEN

log 'Creating a new LXC container'
lxc launch images:ubuntu/20.04/amd64 gitlab-runner -c security.nesting=true

log 'Wait for a few seconds to proper boot up'
sleep 5

log 'Install Docker'
lxc exec gitlab-runner -- /bin/bash -c "apt-get update && apt-get install --yes docker.io && mkdir /root/.docker"

log 'Upload configuration file'
cat <<EOF | lxc exec gitlab-runner -- /bin/bash -c "cat >/root/config.toml"
concurrent = 5
log_level = "info"
check_interval = 0

[session_server]
  session_timeout = 1800

[[runners]]
  name = "My Gitlab Runner"
  url = "https://gitlab.com/"
  token = "$GITLAB_RUNNER_TOKEN"
  executor = "docker"

  [runners.docker]
    tls_verify = false
    image = "ubuntu:latest"
    privileged = false
    disable_entrypoint_overwrite = false
    oom_kill_disable = false
    disable_cache = false
    volumes = ["/var/run/docker.sock:/var/run/docker.sock", "/usr/bin/docker:/usr/bin/docker:ro", "/cache"]
    shm_size = 4294967296
    [runners.docker.tmpfs]
      "/tmp" = "rw,exec,size=32g"

    [runners.docker.services_tmpfs]
      "/tmp" = "rw,exec,size=32g"

### Other, useful options
#   host = ""
#   hostname = ""
#   tls_cert_path = "/root/certs"
#   image = "ruby:2.6"
#   memory = "128m"
#   memory_swap = "256m"
#   memory_reservation = "64m"
#   oom_kill_disable = false
#   cpuset_cpus = "0,1"
#   cpus = "2"
#   dns = ["8.8.8.8"]
#   dns_search = [""]
#   privileged = false
#   userns_mode = "host"
#   cap_add = ["NET_ADMIN"]
#   cap_drop = ["DAC_OVERRIDE"]
#   devices = ["/dev/net/tun"]
#   disable_cache = false
#   wait_for_services_timeout = 30
#   cache_dir = "
EOF

log 'Launching GitLab Runner'
lxc exec gitlab-runner -- docker run \
                            --detach \
                            --name gitlab-runner \
                            --restart always \
                            --volume /etc/localtime:/etc/localtime:ro \
                            --volume /etc/machine_id:/etc/machine_id:ro \
                            --volume /var/run/docker.sock:/var/run/docker.sock \
                            --volume /root/.docker:/root/.docker:ro \
                            --volume /root/config.toml:/etc/gitlab-runner/config.toml:ro \
                            gitlab/gitlab-runner:latest
