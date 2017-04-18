echo 'Moving'
mv lua lua_old || { exit 1; }
mkdir lua || { exit 1; }
echo 'Compiling'
moonc -t lua moon/* || { rm lua -R; mv lua_old lua; exit 1; }
echo 'moon/dmaps/common/sh_cami.lua -> lua/dmaps/common/sh_cami.lua'
cp moon/dmaps/common/sh_cami.lua lua/dmaps/common/sh_cami.lua
echo 'Cleaning up'
rm lua_old -R