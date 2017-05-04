echo 'Moving'
mv lua lua_old || { exit 1; }
mkdir lua || { exit 1; }
echo 'Compiling'
moonc -t lua moon/* || { rm lua -R; mv lua_old lua; exit 1; }
cp -v moon/dmaps/common/sh_cami.lua lua/dmaps/common/sh_cami.lua
cp -v moon/dmaps/client/controls/dscoreboard2_avatar.lua lua/dmaps/client/controls/dscoreboard2_avatar.lua
echo 'Cleaning up'
rm lua_old -R