

Dans skins/Vector/includes/templates/LegacySidebar.mustache
Replace : {{link-mainpage}} : https://openproduct.fr/

WIKI_ROOT=wiki
sed -e 's#{{link-mainpage}}#https://openproduct.fr/#' $WIKI_ROOT/skins/Vector/includes/templates/LegacySidebar.mustache

