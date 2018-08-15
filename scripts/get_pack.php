<?php

// Copyright (C) 2016 DBot

// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,
// modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software
// is furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
// LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


function dummy() {
    header('Content-Type: text/plain; charset=utf8');

    $Bundle = $_GET['bundle'];
    if (!$Bundle) die('No bundle!');

    if (strstr($Bundle, '.')) die('Hack');
    if (strstr($Bundle, '/')) die('Hack');

    $Blacklist = [
        'luapad',
        'gma',
        'git',
        'github',
        'wcache',
        'bundlecache',
        'cache',
    ];

    foreach ($Blacklist as $value)
        if (strpos($Bundle, $value) !== false) die('Hack');

    function Search($path) {
        $readFiles = [];

        foreach (scandir($path) as $value) {
            if ($value[0] === '.') continue;
            
            if (is_dir($path . '/' . $value)) {
                $findFiles = Search($path . '/' . $value);

                foreach ($findFiles as $fil) {
                    array_push($readFiles, $fil);
                }
            } else {
                if (strpos($value, '.lua') === false) continue;
                array_push($readFiles, $path . '/' . $value);
            }
        }

        return $readFiles;
    }

    if (is_file('./luapad/' . $Bundle . '.lua')) {
        $Separator = '////______VLL_PACK_FILE_SEPERATOR______////';
        $output = '';
        $output = $output . 'autorun/' . $Bundle . '.lua' . $Separator;
        $output = $output . file_get_contents('./luapad/' . $Bundle . '.lua');
        $output = $output . $Separator;
        echo $output;
        exit;
    }

    $metap = 'cache/meta/' . $Bundle;
    $LockFileName = 'cache/' . $Bundle . '.lock';

    if (is_file($LockFileName))
        sleep(1);

    $cachep = 'cache/build/' . $Bundle . '.txt';
    $CTime = time();
    $Locked = false;
    $RebuildMetaCache = !is_file($metap);
    $RebuildFileCache = !is_file($cachep);
    $jsonMeta = [];

    $Files = [];
    $BundleLen = 0;

    if (is_dir('./' . $Bundle)) {
        $Files = Search('./' . $Bundle);
        $BundleLen = strlen($Bundle);
    } elseif (is_dir('./git/' . $Bundle)) {
        $Files = Search('./git/' . $Bundle . '/lua');
        $BundleLen = strlen('./git/' . $Bundle . '/lua') - 2;
    } elseif (is_dir('./git/dbot_projects/' . $Bundle)) {
        $Files = Search('./git/dbot_projects/' . $Bundle . '/lua');
        $BundleLen = strlen('./git/dbot_projects/' . $Bundle . '/lua') - 2;
    }

    function rebuildMeta($LockFileName, $Files, $RebuildFileCache, $RebuildMetaCache, $metap, $cachep, $BundleLen) {
        file_put_contents($LockFileName, '');

        $OutputJSON = [];
        $RebuildFileCache = true;
        
        foreach ($Files as $value) {
            array_push($OutputJSON, [
                'file' => $value,
                'pfile' => substr($value, 3 + $BundleLen),
                'stamp' => filemtime($value),
            ]);
        }
        
        file_put_contents($metap, json_encode($OutputJSON));
        unlink($LockFileName);
        return $OutputJSON;
    }

    // var_dump ($RebuildMetaCache);
    if ($RebuildMetaCache) {
        $readMeta = rebuildMeta($LockFileName, $Files, $RebuildFileCache, $RebuildMetaCache, $metap, $cachep, $BundleLen);
        $RebuildMetaCache = false;
    } else {
        $metaFiles = file_get_contents($metap);
        $jsonMeta = json_decode($metaFiles, true);

        foreach ($jsonMeta as $val) {
            // var_dump(filemtime($val['file']) != $val['stamp']);
            if (!is_file($val['file']) or filemtime($val['file']) != $val['stamp']) {
                $jsonMeta = rebuildMeta($LockFileName, $Files, $RebuildFileCache, $RebuildMetaCache, $metap, $cachep, $BundleLen);
                $RebuildMetaCache = false;
                $RebuildFileCache = true;
                break;
            }
        }

        $readMeta = $jsonMeta;
    }

    function rebuildFileCache($LockFileName, $readMeta, $cachep) {
        $Separator = '////______VLL_PACK_FILE_SEPERATOR______////';

        file_put_contents($LockFileName, '');
        $output = '';
        
        foreach ($readMeta as $val) {
            $output = $output . $val['pfile'] . $Separator;
            $output = $output . file_get_contents($val['file']);
            $output = $output . $Separator;
        }

        file_put_contents($cachep, $output);
        unlink($LockFileName);
    }

    if (!$RebuildFileCache) {
        foreach ($readMeta as $val) {
            $hit = false;

            foreach ($Files as $val2) {
                if ($val2 === $val['file']) {
                    $hit = true;
                    break;
                }
            }

            if (!$hit) {
                rebuildMeta();
                break;
            }
        }
        
        foreach ($Files as $val2) {
            $hit = false;

            foreach ($readMeta as $val) {
                if ($val2 === $val['file']) {
                    $hit = true;
                    break;
                }
            }

            if (!$hit) {
                rebuildMeta();
                break;
            }
        }
    }

    if ($RebuildFileCache) {
        rebuildFileCache($LockFileName, $readMeta, $cachep);
    }

    header('Location: ' . $cachep);
}

dummy();
