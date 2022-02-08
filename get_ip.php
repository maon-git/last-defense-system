#!/bin/php
<?php 

$jp_ip4 = "##### Last Defense System #####" . "\n\n"; 

// Get from the list of UAs to block.
$file = fopen("/home/hogehoge/hogehoge.domain/public_html/cron/block_ua.txt", "r");

if($file){
  while ($line = fgets($file)) {
    $jp_ip4 .= $line;
  }
}

fclose($file);

    $jp_ip4 .= "\n\n";

    // Allow when ALL RequireXX condition are met.
    $jp_ip4 .= "<RequireAll>" . "\n\n";

// Get from the list of Remote-Hosts and IPs to block. 
$file = fopen("/home/hogehoge/hogehoge.domain/public_html/cron/block_ip.txt", "r");
 
if($file){
  while ($line = fgets($file)) {
    $jp_ip4 .= $line;
  }
}
 
fclose($file);

    $jp_ip4 .= "\n\n";

    // Permission is granted when ONE of these conditions is met.
    $jp_ip4 .= "<RequireAny>" . "\n\n";

    // APNIC URL
    $fp_arr = file("http://ftp.apnic.net/stats/apnic/delegated-apnic-latest");

    foreach( $fp_arr AS $v )
    {
        if( preg_match('/ipv4/', $v) && preg_match('/JP/', $v) )
        {
            $_line = explode('|', $v);
            $_line[3];

            $prefix = log($_line[4]) / log(2);
            $prefix = 32 - $prefix;

            $jp_ip4 .= "Require ip " . $_line[3] . "/" . $prefix . "\n";
        }
    }

    // Foreign IPs, but allow Remote-Hosts.
    $jp_ip4 .= "\n";
    $jp_ip4 .= "Require host googlebot.com" . "\n";
    $jp_ip4 .= "Require host google.com" . "\n"; 
    $jp_ip4 .= "Require host letsencrypt.org" . "\n\n"; 
    $jp_ip4 .= "</RequireAny>" . "\n\n"; 

    $jp_ip4 .= "</RequireAll>" . "\n\n"; 

    print $jp_ip4;
?>
