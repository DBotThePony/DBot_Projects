<?php

//
// Copyright (C) 2016 DBot
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

function dummy() {
    $Seperator = '----______VLL_PACK_FILE_SEPERATOR______----';

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
        $output = '';
        $output = $output . 'autorun/' . $Bundle . '.lua' . $Seperator;
        $output = $output . file_get_contents('./luapad/' . $Bundle . '.lua');
        $output = $output . $Seperator;
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
    $RebuildFileCache = !is_file($cachep) or filemtime($cachep) + 3600 < $CTime;
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

    if ($RebuildMetaCache) {
        $readMeta = rebuildMeta($LockFileName, $Files, $RebuildFileCache, $RebuildMetaCache, $metap, $cachep, $BundleLen);
        $RebuildMetaCache = false;
    } else {
        $metaFiles = file_get_contents($metap);
        $jsonMeta = json_decode($metaFiles, true);

        foreach ($jsonMeta as $val) {
            if (!is_file($val['file'])) {
                $jsonMeta = rebuildMeta($LockFileName, $Files, $RebuildFileCache, $RebuildMetaCache, $metap, $cachep, $BundleLen);
                $RebuildMetaCache = false;
                break;
            }
        }

        $readMeta = $jsonMeta;
    }

    function rebuildFileCache($LockFileName, $readMeta, $cachep) {
        file_put_contents($LockFileName, '');
        $output = '';
        
        foreach ($readMeta as $val) {
            $output = $output . $val['pfile'] . $Seperator;
            $output = $output . file_get_contents($val['file']);
            $output = $output . $Seperator;
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
