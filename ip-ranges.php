#!/usr/bin/env php
<?php

function amazon_ranges(): ?array
{
  try
  {
    $data = file_get_contents('https://ip-ranges.amazonaws.com/ip-ranges.json');
    $ranges = json_decode($data, true, 512, JSON_PRESERVE_ZERO_FRACTION | JSON_THROW_ON_ERROR);
  }
  catch (JsonException)
  {
    $ranges = [];
  }

  $prefixes_v4 = [];
  $prefixes_v6 = [];

  foreach ($ranges['prefixes'] ?? [] as $range)
  {
    $prefixes_v4[] = $range['ip_prefix'];
  }

  foreach ($ranges['ipv6_prefixes'] ?? [] as $range)
  {
    $prefixes_v6[] = $range['ipv6_prefix'];
  }

  $prefixes_v4 = array_unique($prefixes_v4);
  sort($prefixes_v4);

  $prefixes_v6 = array_unique($prefixes_v6);
  sort($prefixes_v6);

  return array_merge($prefixes_v4, $prefixes_v6);
}

function cloudflare_ranges(): ?array
{
  $data = file_get_contents('https://www.cloudflare.com/ips-v4');
  $lines_v4 = explode("\n", $data);
  if (is_string($lines_v4)) return null; // should have been exploded into array

  foreach ($lines_v4 as $line)
  {
    $slash = strpos($line, '/'); // cidr?
    $ip = ($slash === false ? $line : substr($line, 0, $slash)); // cidr => ip
    if (filter_var($ip, FILTER_VALIDATE_IP) === false) return null; // invalid ip
  }

  $lines_v4 = array_unique($lines_v4);
  sort($lines_v4);

  $data = file_get_contents('https://www.cloudflare.com/ips-v6');
  $lines_v6 = explode("\n", $data);
  if (is_string($lines_v6)) return $lines_v4; // should have been exploded into array

  foreach ($lines_v6 as $line)
  {
    $slash = strpos($line, '/'); // cidr?
    $ip = ($slash === false ? $line : substr($line, 0, $slash)); // cidr => ip
    if (filter_var($ip, FILTER_VALIDATE_IP) === false) return $lines_v4; // invalid ip
  }

  $lines_v6 = array_unique($lines_v6);
  sort($lines_v6);

  return array_merge($lines_v4, $lines_v6);
}

$ranges = [
  'Amazon' => amazon_ranges(),
  'Cloudflare' => cloudflare_ranges(),
];

echo '## Documentation: <https://nginx.org/en/docs/http/ngx_http_realip_module.html>' . PHP_EOL;
echo '## Used to change the client address and optional port to those sent in the specified header field, typically X-Forwarded-For.' . PHP_EOL;
echo '## Auto-generated IP ranges' . PHP_EOL;
echo '## ' . date(DATE_ATOM) . PHP_EOL;

foreach ($ranges as $origin => $cidrs)
{
  if (!$cidrs) continue;
  echo PHP_EOL . '# ' . $origin . PHP_EOL;
  foreach ($cidrs ?? [] as $cidr)
  {
    echo 'set_real_ip_from ' . $cidr . PHP_EOL;
  }
}
