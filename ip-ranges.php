#!/usr/bin/env php
<?php

$data = file_get_contents('https://ip-ranges.amazonaws.com/ip-ranges.json');
$ranges = json_decode($data);
$nginx = fopen('php://stdout', 'w');
$prefixes = array();

foreach ($ranges->prefixes as $range) {
  $prefixes[] = $range->ip_prefix;
}

sort($prefixes);
$prefixes = array_unique($prefixes);

foreach ($prefixes as $ip_prefix) {
  fwrite($nginx, 'set_real_ip_from ' . $ip_prefix . ';' . PHP_EOL);
}

fclose($nginx);
