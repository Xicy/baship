export_docker() { 
  sed '1,/^_DATA_/d' $0 | tar xzf -
}

update() {
  $(curl -s https://api.github.com/repos/Xicy/baship/releases/latest | grep "browser_download_url.*"  | cut -d '"' -f 4 | wget -qi - -O- > $0)
  echo "Update Successfully"
  exit 0
}

