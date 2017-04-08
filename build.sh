echo 'Moving'
mv lua lua_old || { exit 1; }
mkdir lua || { exit 1; }
echo 'Compiling'
moonc -t lua moon/* || { rm lua; mv lua_old lua; exit 1; }
echo 'Cleaning up'
rm lua_old -R