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
	if (!$Bundle)
		die('No bundle!');

	if (strstr($Bundle, '.'))
		die('Hack');

	$Blacklist = [
		'luapad',
		'gma',
		'git',
		'github',
		'wcache',
		'bundlecache',
		'cache',
	];

	$Cache = [
		'neurotec',
		'server_playermodels',
		'server_cars',
	];

	foreach ($Blacklist as $value)
		if (strpos($Bundle, $value) !== false)
			die('Hack');

	$Files = [];

	function Search($path)
	{
		global $Files;
		$Rep = scandir($path);
		
		foreach ($Rep as $value)
		{
			if ($value[0] === '.') continue;
			
			if (is_dir($path . '/' . $value))
				Search($path . '/' . $value);
			else
			{
				if (strpos($value, '.lua') === false) continue;
				array_push($Files, $path . '/' . $value);
			}
		}
	}

	if (is_file('./luapad/' . $Bundle . '.lua'))
	{
		$output = '';
		$output = $output . 'autorun/' . $Bundle . '.lua' . $Seperator;
		$output = $output . file_get_contents('./luapad/' . $Bundle . '.lua');
		$output = $output . $Seperator;
		echo $output;
		exit;
	}

	$metap = 'cache/meta/' . $Bundle;
	$lockfile = 'cache/' . $Bundle . '.lock';

	//if (is_file($lockfile))
		//sleep(1);

	$cachep = 'cache/build/' . $Bundle . '.txt';
	$CTime = time();
	$Locked = false;
	$RebuildFileCache = !is_file($metap) or filemtime($metap) + 120 < $CTime;

	if ($RebuildFileCache) {
		$Locked = true;
		
		file_put_contents($lockfile, '');
		if (is_dir('./' . $Bundle)) {
			Search('./' . $Bundle);
			$len = strlen($Bundle);
		} elseif (is_dir('./git/' . $Bundle)) {
			Search('./git/' . $Bundle . '/lua');
			$len = strlen('./git/' . $Bundle . '/lua') - 2;
		} elseif (is_dir('./git/dbot_projects/' . $Bundle)) {
			Search('./git/dbot_projects/' . $Bundle . '/lua');
			$len = strlen('./git/dbot_projects/' . $Bundle . '/lua') - 2;
		}
		
		$OutputJSON = [];
		
		$CacheFileTime = filemtime($cachep);
		
		foreach ($Files as $value) {
			$CurrFileTime = filemtime($value);
			
			if ($CurrFileTime > $CacheFileTime)
				$RebuildFileCache = true;
			
			array_push($OutputJSON, [
				'file' => $value,
				'pfile' => substr($value, 3 + $len),
				'stamp' => $CurrFileTime,
			]);
		}
		
		// file_put_contents($metap, json_encode($OutputJSON));
		
		$Locked = true;
		
		//file_put_contents($lockfile, '');
		$output = '';
		
		foreach ($OutputJSON as $val) {
			$output = $output . $val['pfile'] . $Seperator;
			$output = $output . file_get_contents($val['file']);
			$output = $output . $Seperator;
		}
		
		file_put_contents($cachep, $output);
		
		if (is_file($cachep . '.gz'))
			unlink($cachep . '.gz');
		
		// exec('"C:\\Program Files\\Git\\bin\\gzip" "' . getcwd() . '/' . $cachep . '"');
		file_put_contents($cachep, $output);
		
		$Locked = false;
		//unlink($lockfile);
		//sleep(0.2);
	}

	header('Location: ' . $cachep);
}

dummy();
