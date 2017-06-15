mv lua lua_old || { exit 1; }
mkdir lua || { exit 1; }
moonc -t lua moon/* || { rm lua -R; mv lua_old lua; exit 1; }
mkdir lua/tf2scripts
cp moon/tf2scripts/* lua/tf2scripts -R -v
rm lua_old -R