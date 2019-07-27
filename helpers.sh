exportDockerFiles() { 
  sed '1,/^_DATA_/d' $0 | tar xzf -
}

selfUpdate() {
  curl -s -L "$(curl -s https://api.github.com/repos/Xicy/baship/releases/latest | grep "browser_download_url.*"  | cut -d '"' -f 4)" -o $0
  echo "Update Successfully"
  exit 0
}

installDocker() {
	wget -q -O - "http://get.docker.com"  | bash
    curl -s -L "$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep "browser_download_url.*docker-compose-$(uname -s)-$(uname -m)\"" | cut -d '"' -f 4 )" -o /usr/local/bin/docker-compose
	chmod +x /usr/local/bin/docker-compose
}

