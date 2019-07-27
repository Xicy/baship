#!/usr/bin/env bash
rm -f baship
cp baship.sh baship
VERSION="VERSION=\"$(git describe --tags `git rev-list --tags --max-count=1`)\""
sed -i "s/#VERSION/${VERSION}/g" baship
sed -i -e '/#CONSTANTS/{r constans.sh' -e 'd}' baship
sed -i -e '/#HELPERS/{r helpers.sh' -e 'd}' baship
echo "
exit
_DATA_" >> baship
tar -czf - .docker >> baship
