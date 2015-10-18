#!/usr/bin/perl
  print "\n\n";  
  open (userstxt, "<users/users.txt");
  flock(userstxt, 1);
  @users = <userstxt>;
  close userstxt;

  $b = 0;
  foreach $a(@users)
  {
    $b++;
    chomp $a;

    open (privatestxt, "<privates/$b/maxindex.txt");
    flock(privatestxt, 1);
    $privates = <privatestxt>;
    close privates;

    print "$b|$a|$privates\n";
  }
