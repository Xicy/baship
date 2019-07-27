#!/usr/bin/env bash
VERSION="VERSION="
EXPORTFUNC="export_data() { \
sed '1,\/^_DATA_\/d' \$0 | tar xzf -; \
}"
rm -f baship
cp baship.sh baship
sed -i "s/#EXPORTFUNC/${EXPORTFUNC}/g" baship
echo "
exit
_DATA_" >> baship
tar -czf - .docker >> baship
