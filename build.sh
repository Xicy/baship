#!/usr/bin/env bash
rm -f baship
cp baship.sh baship
VERSION="VERSION=\"$(git describe --tags `git rev-list --tags --max-count=1`)\""
sed -i "s/#VERSION/${VERSION}/g" baship
EXPORTFUNC="export_docker() { sed '1,\/^_DATA_\/d' \$0 | tar xzf -; }"
sed -i "s/#EXPORTFUNC/${EXPORTFUNC}/g" baship
echo "
exit
_DATA_" >> baship
tar -czf - .docker >> baship
