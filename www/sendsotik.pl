sub sendsotik{
  $name = param(name);
  $sotoviy = param(sotoviy);
  $text = param(text);

  if(param(action2) eq "�������")
  {
    open (NEW,">sms_buf.txt");
    open (OLD,"sms.txt");
    $i=0;
    while (<OLD>)
    {
      $i++;
      ($usernamebuf, $numbuf, $ipbuf, $combuf) = split(/\|/,$_);

      if(param($i) ne "on"|$usernamebuf ne $UserName)
      {
        print NEW $_;
      }
    }
    close(OLD);
    close(NEW);
    rename("sms.txt", "sms_old.txt");
    rename("sms_buf.txt", "sms.txt");

    print "<center><b>�����a ��������.</b></center>";
    &htmlend;
    exit;
  }


  if($name eq ""|$sotoviy eq ""|not($sotoviy =~ m/\+7(\d+)/))
  {
    &sot_error;
  }

  $text =~ s/\n/<br>/gi;

  open (sms,">>sms.txt") || open(sms, ">sms.txt");;
  flock(sms, 2);
  print sms "$name|$sotoviy|$ENV{REMOTE_ADDR}|$text\n";
  close(sms);

  print "<center><b>����� �������.</b></center>";
  &htmlend;
  exit;
}

sub sendsotik_forma{

print <<FORMA;
<div align=center><b><font size=4>����� ��� �������� �� SMS ��������</b></font><br>
� ������ �������� ��� �� ������� ����� ��������� �������� ������ ������� � FM.
<br>
<table border=0 cellspacing=0 cellpadding=2>
<form action="" method=POST>
<input type="hidden" name="action" value=send>
<input type="hidden" name="mode" value=sms>
<input type="hidden" name="name" value="$UserName">
<tr>
    <td nowrap>��� ����� ��������:</td>
    <td width=75%><input type=text size=53 name=sotoviy></td>
</tr>
<tr>
    <td> </td>
    <td width=75%>������� � ���� +7������������, �������� +79531108892</td>
</tr>
<tr>
    <td colspan=2>��� ����������� (����� �� ���������):</td>
</tr>
<tr>
    <td colspan=2><textarea type=text name=text rows=5 cols=75 ></textarea></td>
</tr>
<tr>
    <td colspan=2></td>
</tr>
<tr>
    <td colspan=2><input type=submit style=\"background-color: $tseriy;\" value=���������></td>
</tr>
<tr>
    <td colspan=2> <table border=0 cellspacing=0 cellpadding=2 width="100%">


FORMA


  open (SMS_FILE, "<sms.txt");
  flock(SMS_FILE, 1);
  @smslist = <SMS_FILE>;
  close SMS_FILE;

  $i=0;
  $j=0;

  print "<tr><td> ";
  print "<tr><td> ";
  print "<tr><td> ";
  print "<tr><td colspan=5><b>������ �������� ���� �� ������� ���������� ���-��������";
  print "<tr><td>�<td><td>�������<td>IP<td>����������";

  for(@smslist)
  {
    $i++;
    ($usernamebuf, $numbuf, $ipbuf, $combuf) = split(/\|/,$_);
    if($numpovtorbuf{$numbuf}>1){$numbuf = "<font color=red>$numbuf"}
    else{$numbuf = "<font color=#408080>$numbuf"}
    $numpovtorbuf{$usernamebuf}++;

    if($UserName eq $usernamebuf)
    {
      $j ++;
      print "<tr bgcolor=$sseriy><td>$j<td><input type=checkbox name=$i><td>$numbuf<td>$ipbuf<td>$combuf";
    }
  }
  print "<tr bgcolor=$sseriy><td colspan=6><input type=submit style=\"background-color: $tseriy;\" name=action2 value=�������>";

  print "</form>";
  print "</table>";

}

sub sot_error
  {
     print "<br><br><center><b>���������� ��������� ��� � ����� �������� � ���� +7������������.</b></center>";
     &htmlend;
     exit;
  }
1;
