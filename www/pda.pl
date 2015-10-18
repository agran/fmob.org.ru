sub show_pda{
  &cookies_create;
  print header(-cookie=>[$c1, $c2, $c3, $c4], -charset=>"windows-1251");

  print <<header;
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<meta http-equiv=Content-Type content="text/html; charset=windows-1251">
<link href="main.css" type="text/css" rel="stylesheet">
<title>FlashMob в Краснодаре - PDA версия</title>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bottommargin="0">
<center>
<a href="$site">Главная</a> |
<a href="?mode=voting">Рейтинг сценариев</a> |
<a href="?mode=next">Предстоящий моб</a> |
<a href="?mode=past">Прошедшие мобы</a> |
<a href="?mode=sms">SMS-рассылка</a> |
<a href="?mode=mobbers">Мобберы</a> |
<a href="?mode=forum">Форум</a></center>
header

  open(attention, "<attention.txt");
  $attention = <attention>;
  close(attention);
  $attentionbuf = "";
  if($attention ne "")
  {
    $attention = &text_process($attention);
    print "<br><table cellpadding=\"2\" cellspacing=\"1\" bgcolor=\"$cherniy\" width=\"100%\"><tr bgcolor=\"$beliy\"><td align=center>$attention</td></tr></table><br>";
  }

  $playtype = 2;
  &readindexofplay;
  $nextplay = $indexofplay[0];

  if($nextplay>0)
  {
    &next_print;
  }
  $playtype = 1;
  &readindexofplay;
  &last3new_print;
  &top3best_print;
  $playtype = 3;
  &readindexofplay;
  &last3past_print;
  &lastthread_print;

  print <<end1;
<center>
</body>
</html>
end1
}

1;
