#!/usr/bin/perl
  print "\n\n";
  open (userstxt, "<users/users.txt");
  flock(userstxt, 1);
  @users = <userstxt>;
  close userstxt;

  $b = 0;
  open (icqtxt, ">icq.txt");
  flock(icqtxt, 2);

  foreach $a(@users)
  {
    $b++;
    chomp $a;

    if(substr($a,0,1) eq ";")
    {
      print icqtxt "$b|$a|\n";
      next;
    }

    open (userinfotxt, "<users/$b.txt");
    flock(userinfotxt, 1);
    @userinfo = <userinfotxt>;
    close userinfotxt;

    chomp $userinfo[5];
    $userinfo[5] =~ s~-~~ig;
    $userinfo[5] =~ s~ ~~ig;

    print icqtxt "$b|$a|$userinfo[5]\n";
  }
  close icqtxt;

