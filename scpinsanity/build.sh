mv lua lua_old || { exit 1; }
mkdir lua || { exit 1; }
moonc -t lua moon/* || { rm lua -R; mv lua_old lua; exit 1; }
rm lua_old -R