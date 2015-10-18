#!/usr/local/bin/perl
use POSIX;
use CGI qw/:standard/;

$userid = param(userid);
($cherniy, $ttseriy, $tseriy, $t2seriy, $seriy, $sseriy, $beliy) = ("#000000", "#707070", "#e0e0e0", "#e7e7e7", "#f0f0f0", "#f7f7f7", "#ffffff");
if($userid ne "")
{
  open (userinfo, "<users/$userid.txt");
  flock(userinfo, 1);
  @userinfo = <userinfo>;
  close userinfo;

  chomp $userinfo[26];
  if(length($userinfo[26] > 10))
  {
    ($cherniy, $ttseriy, $tseriy, $t2seriy, $seriy, $sseriy, $beliy) = split(/;/,$userinfo[26]);
  }
}

print <<huy;


<style type="text/css">

dfsdf { }

body {
  font-size: 13px;
  color: $cherniy;
  font-family: Tahoma;
  background-color: $beliy;
  align: center
}

td {
  align: center;
  font-size: 13px;
  font-family: Tahoma;
}


.td2 {
  background-color: $sseriy;
  text-align: right;
}

a, a:visited, a:active, a:hover {
  text-decoration: underline;
  color: $cherniy;
}

a:hover {
  color: $ttseriy;
}

.m, a:visited.m, a:active.m, a:hover.m {
  text-decoration: underline;
  color: $cherniy;
  font-size: 75%;
}

a:hover.m {
  color: $ttseriy;
}

.h, a:visited.h, a:active.h, a:hover.h {
  text-decoration: underline;
  color: $sseriy;
}

.s, a:visited.s, a:active.s, a:hover.s {
  text-decoration: underline;
  color: $ttseriy;
}

.menu, a:visited.menu, a:active.menu, a:link.menu, a:hover.menu {
  text-decoration: none;
  font-weight: bold;
  border-top: 0px;
  border-left: 0px $cherniy solid;
  border-right: 1px $cherniy solid;
  border-bottom: 0px $ttseriy solid;
  padding-left: 5px;
  padding-right: 5px;
  color: $cherniy
}

a:hover.menu {
  background-color: $beliy;
}

.vot, a:visited.vot, a:active.vot, a:link.vot, a:hover.vot{
  color: $cherniy;
  text-decoration: none;
  background-color: #D4D0C8;
  font-family: Courier;
  font-weight:bold;
  border-top: 1px $beliy solid;
  border-left: 1px $beliy solid;
  border-right: 1px #808080 solid;
  border-bottom: 1px #808080 solid;
  padding: 2px 4px 2px 4px;
}

a:hover.vot{
  background-color: #D4D0C8;
  border-top: 1px #808080 solid;
  border-left: 1px #808080 solid;
  border-right: 1px $beliy solid;
  border-bottom: 1px $beliy solid;
}

.adm, a:visited.adm, a:active.adm, a:hover.adm {
  color: #BA7C0A;
  text-decoration: none;
}

a:hover.adm {
  color: #BA7C77;
  text-decoration: underline
}

kbd {
  font-family: Courier;
  font-weight: bold;
}

.tableq1 {
  width: 99%;
  padding: 2px 0px 3px 0px;
  border: 0px;
}
.qbackb {
  background-color: $cherniy
}
.qbackr1 {
  background-color: $t2seriy
}
.qbackr2 {
  background-color: $sseriy
}

input, textarea, select {
  border:1px solid $cherniy;
  font-family: Tahoma;
  font-size: 13px;
  padding-left:2px; padding-right:2px;
  color: $cherniy;
  background-color: $beliy;
}

#CODE {
 padding:2px; font-family: Courier New, Courier, Verdana, Arial;
 color: $cherniy;
 background-color: $beliy;
 border: 1px solid $cherniy;
}
-->
</STYLE>

huy


