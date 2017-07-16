
rm -rf lua
mkdir lua || { exit 1; }
moonc -t lua moon/* || { rm lua -R; mv lua_old lua; exit 1; }
cp lua_src/* lua/ -Rv
