#!/usr/bin/perl
#
#           RiSearch
#
# web search engine, version 0.99.02
# (c) Sergej Tarasov, 2000
#
# Homepage: http://risearch.webservis.ru/
# email: risearch@webservis.ru

use locale;
use POSIX qw(locale_h);


# File extensions to index
$file_ext = '\.(txt)$';

# List of directories, which should not be indexed
$no_index_dir = '(img|image|temp|tmp|cgi-bin)$';

# List of files, which should not be indexed
$no_index_files = '(privates|find|boards|find|image|attention|hide_mails|lastplay|log|mail_log|usersreg|usersonsite|subscribe|sms|mesto|old|del_by|time|info|users|plays.txt|maxindex|smiles.txt|rules.txt|lastthreads|yahoo|fotos|referendum|del)';


# Directory where yours html files are located
# Type "." for the current directory
#$base_dir = $ENV{DOCUMENT_ROOT};


# Base URL of your site
if($ENV{DOCUMENT_ROOT} eq "z:/home/test1.ru/www")
{
  $base_url = "http://test1.ru/";
  $base_dir = $ENV{DOCUMENT_ROOT};
}
else
{
  $base_url = "http://fmob.org.ru/";
  $base_dir = "/home/vipdesig/public_html/fmoborg";
}

# Full word indexing ("YES" or "NO")
$FULL_WORD = "YES";

#index or not numbers (set   $numbers = ""   if you don't want to index numbers)
$numbers = '0-9';

#minimum word length to index
$min_length = 3;

#number of results per page
$res_num=20;

#use escape chars (like &Egrave; or &x255;)
$use_esc = "YES";

#index META tags
$use_META = "YES";

#index IMG ALT tag
$use_ALT = "YES";

# site size
# 1 - Tiny    ~1Mb
# 2 - Medium  ~10Mb
# 3 - Big     ~50Mb
# 4 - Large   >100Mb
$site_size = 3;

# Delete hyphen at the end of strings
$del_hyphen = "YES";

# Define length of page description in output
# and use META description ("YES") or first "n" characters of page ("NO")
$descr_size = 256;
$use_META_descr = "NO";

# List of stopwords
$use_stop_words = "YES";
@stop_words = qw(and any are but can had has have her here him his
 how its not our out per she some than that the their them then there
 these they was were what you);

# Change below only if you need multilanguage support
# With default settings script will work with
# English, Russian (win1251 encoding) and most European languages

# Capital letters
$CAP_LETTERS = '\xC0-\xDF\xA8';

# Lower case letters
$LOW_LETTERS = '\xE0-\xFF\xB8';

# Change this as above
sub to_lower_case {
   my $str = shift;
   $str =~ tr{\xC0-\xDF\xA8}{\xE0-\xFF\xB8};
   return $str;
}

#--- end of configuration ---

if ($site_size == 1) { $HASHSIZE = 20001 }
elsif ($site_size == 3) { $HASHSIZE = 100001 }
elsif ($site_size == 4) { $HASHSIZE = 300001 }
else { $HASHSIZE = 50001 }

%stop_words = ();
if ($use_stop_words eq "YES") {
    foreach $word (@stop_words) { $stop_words{$word} = "" }
}

$| = 1;

#DEFINE CONSTANTS
$cfn = 0;
$kbcount = 0;
if ($use_esc eq "YES") { &html_esc() }

if (exists($ENV{'GATEWAY_INTERFACE'})) {print "Content-Type: text/plain\n\n"}

open FINFO, ">finfo" or die "Could not open finfo.";
open SITEWORDS, ">sitewords" or die "Could not open sitewords.";
open WORD_IND, ">word_ind" or die "Could not open word_ind.";
binmode(WORD_IND);

@time=localtime(time);
$time="$time[2]:$time[1]:$time[0]";
print "Scan started: $time\n";


&scan_files($base_dir);

@time=localtime(time);
$time="$time[2]:$time[1]:$time[0]";
print "Scan finished: $time\n";
print "Creating databases. Please wait, this can take several minuts.\n";

close(FINFO);

    foreach $word (sort keys %words) {
            $wordpos{$word} .= pack("NN", tell(SITEWORDS), tell(WORD_IND) );
            print SITEWORDS "$word\n";
            print WORD_IND pack("N", length($words{$word}));
            print WORD_IND $words{$word};
    };

close(SITEWORDS);
close(WORD_IND);

    &build_hash;

@time=localtime(time);
$time="$time[2]:$time[1]:$time[0]";
print "Indexing finished: $time\n";


sub  scan_files {

     my $dir=$_[0];
     my (@dirs,@files,$filename,$newdir,$list,$url);

     opendir(DIR,$dir) or (warn "Cannot open $dir: $!" and next);
     @dirs=grep {!(/^\./) && -d "$dir/$_"} readdir(DIR);
     rewinddir(DIR);
     @files=grep {!(/^\./) && /$file_ext/i && -f "$dir/$_"} readdir(DIR);
     closedir (DIR);

     for $list(0..$#dirs) {
              if ($dirs[$list] =~ m#$no_index_dir#i) {next};
         $newdir=$dir."/".$dirs[$list];
         &scan_files ($newdir);
     }
     for $list(0..$#files) {
         $filename=$dir."/".$files[$list];
         if ($filename =~ m#$no_index_files#i) {next};
         ($url = $filename) =~ s/^$base_dir\///;
         $url = $base_url.$url;
         &index_file($filename,$url);
         $cfn++;
     }
     return 1;
}


sub index_file {
    my $filename=$_[0];
    my $url=$_[1];
#    local $/;
    open FILE, $filename;
    @dum = stat(FILE);
    $size = int($dum[7] / 1024);
    $kbcount += $size;
    print "$cfn -> $filename; totalsize -> $kbcount\n";
    @body = ();
    @body = <FILE>;

    for(@body)
    {
      chomp $_;
      $_ =~ s~\n~ ~ig;
      $_ =~ s~\<br\>~ ~ig;
      $_ =~ s~\[(.+?)\]~~ig;

    }

    if($filename =~ /plays/i)
    {
      $bod = &Get_User_Name_by_id($body[3]);
      $bod = "$bod $body[5] $body[6] $body[16]";
    }
    if($filename =~ /messages/i)
    {
      ($forumid = $filename) =~ s/(.+?)\/(\d+).txt/$2/;
      $buf = &getforumname ($forumid);

      foreach (@body)
      {
          ($avtorbuf, $timebuf, $textbuf, $imagebuf, $editbybuf, $edittimebuf, $hidebuf)=split(/\|/,$_);
          if($hidebuf ne "1")
          {
            if($search_name eq "1")
            {
              $_ = &Get_User_Name_by_id($avtorbuf)." ".$textbuf." ";
            }
            else
            {
              $_ = $textbuf;
            }
            $_ = "$_\(\|\~\)";
          }
          else
          {
            $_ = "";
          }
      }

      $bod = "$buf @body";

    }
    $bod =~ s~\[(.+?)\]~~isg;
    $bod =~ s~<br>~ ~ig;
    $plain_text = $bod;
    $plain_text =~ s/\s+/ /gs;
    if ($use_esc eq "YES") { $plain_text =~ s/(&.*?;)/&esc2char($1)/egs; }
    $plain_text =~ s/ {2,}/ /gs;
    @wwd = ($plain_text =~ m/([a-zA-Z$CAP_LETTERS$LOW_LETTERS$numbers]+-[a-zA-Z$CAP_LETTERS$LOW_LETTERS$numbers]+)/gs);
    $wwd = join " ", @wwd;
    $plain_text =~ s/[^a-zA-Z$CAP_LETTERS$LOW_LETTERS$numbers]/ /gs;
    $plain_text = $plain_text." ".$wwd;
    $plain_text =~ s/ {2,}/ /gs;
    $plain_text =~ tr/A-Z/a-z/;
    $plain_text = to_lower_case($plain_text);
    $f_termcount_db = 0;
    while ($plain_text =~ m/\b(\S+)\b/gs)
    {
      my $term = $1;
      $f_termcount_db += length $term;
    }

    ($filename2 = $filename) =~ s/^$base_dir\///;
    ($filename3 = $filename2) =~ s/(.+?)\/(\d+).txt/$2/;

    $fileinfo = $filename3."::".$filename2."::".$f_termcount_db;
    $pos = tell(FINFO);
    print FINFO "$fileinfo\n";

    @results=split (/ /,$plain_text);
    %seen = ();
    @uniq = ();
    foreach $item (@results) {
            if (exists($stop_words{$item})) { next }
        unless ($seen{$item}) {
            $seen{$item} = 1;
            push(@uniq, $item);
        };
    };
    foreach (@uniq){
       chomp($_);
       if (length($_) >= $min_length) { $words{$_}.= pack("N", $pos) }
    }
};     # sub index_file



sub build_hash {

    for ($i=0; $i<$HASHSIZE; $i++) {$hash_array[$i] = ""};
    foreach $word (keys %words) {
        @letters = unpack("C*", $word);
        if ($FULL_WORD eq "YES") { $subbound = scalar(@letters)-3 }
        else { $subbound = 1 }
        if (scalar(@letters)==3) {$subbound = 1}

        for ($i=0; $i<$subbound; $i++){
                $a = $letters[$i];
                   $b = $letters[$i+1];
                $c = $letters[$i+2];
                $d = $letters[$i+3];
                $num = int( ($a*14511 - $b*13779 + $c*$d*94333)/5 ) % $HASHSIZE;
                $hash_array[$num] .= ($word."::");
            };   # for $i
    };   # foreach $word

    open HASH, ">hash" or die "Could not open hash.";
    binmode(HASH);
    open HASHWORDS, ">hashwords" or die "Could not open hashwords.";
    binmode(HASHWORDS);

    $zzz = pack("N", 0);
    print HASHWORDS $zzz;
    for ($i=0; $i<$HASHSIZE; $i++){

        if ($hash_array[$i] eq "") {print HASH $zzz};
        if ($hash_array[$i] ne "") {
            @dum = split (/::/,$hash_array[$i]);
            $pos = pack("N", tell(HASHWORDS));
            print HASH $pos;
            $wnum = pack("N", scalar(@dum));
            print HASHWORDS $wnum;
            foreach (@dum) { print HASHWORDS $wordpos{$_} };
        };   # if

    }; # for $i

close(HASH);
close(HASHWORDS);

};     # sub build_hash


sub html_esc {
    %html_esc = (
        "&Agrave;" => chr(192),
        "&Aacute;" => chr(193),
        "&Acirc;" => chr(194),
        "&Atilde;" => chr(195),
        "&Auml;" => chr(196),
        "&Aring;" => chr(197),
        "&AElig;" => chr(198),
        "&Ccedil;" => chr(199),
        "&Egrave;" => chr(200),
        "&Eacute;" => chr(201),
        "&Eirc;" => chr(202),
        "&Euml;" => chr(203),
        "&Igrave;" => chr(204),
        "&Iacute;" => chr(205),
        "&Icirc;" => chr(206),
        "&Iuml;" => chr(207),
        "&ETH;" => chr(208),
        "&Ntilde;" => chr(209),
        "&Ograve;" => chr(210),
        "&Oacute;" => chr(211),
        "&Ocirc;" => chr(212),
        "&Otilde;" => chr(213),
        "&Ouml;" => chr(214),
        "&times;" => chr(215),
        "&Oslash;" => chr(216),
        "&Ugrave;" => chr(217),
        "&Uacute;" => chr(218),
        "&Ucirc;" => chr(219),
        "&Uuml;" => chr(220),
        "&Yacute;" => chr(221),
        "&THORN;" => chr(222),
        "&szlig;" => chr(223),
        "&agrave;" => chr(224),
        "&aacute;" => chr(225),
        "&acirc;" => chr(226),
        "&atilde;" => chr(227),
        "&auml;" => chr(228),
        "&aring;" => chr(229),
        "&aelig;" => chr(230),
        "&ccedil;" => chr(231),
        "&egrave;" => chr(232),
        "&eacute;" => chr(233),
        "&ecirc;" => chr(234),
        "&euml;" => chr(235),
        "&igrave;" => chr(236),
        "&iacute;" => chr(237),
        "&icirc;" => chr(238),
        "&iuml;" => chr(239),
        "&eth;" => chr(240),
        "&ntilde;" => chr(241),
        "&ograve;" => chr(242),
        "&oacute;" => chr(243),
        "&ocirc;" => chr(244),
        "&otilde;" => chr(245),
        "&ouml;" => chr(246),
        "&divide;" => chr(247),
        "&oslash;" => chr(248),
        "&ugrave;" => chr(249),
        "&uacute;" => chr(250),
        "&ucirc;" => chr(251),
        "&uuml;" => chr(252),
        "&yacute;" => chr(253),
        "&thorn;" => chr(254),
        "&yuml;" => chr(255),
        "&nbsp;" => " ",
        "&amp;" => " ",
        "&quote;" => " ",
    );

}


sub esc2char {
    my ($esc) = @_;
    my $char = "";
    if ($esc =~ /&[a-zA-Z]*;/) { $char = $html_esc{$esc} }
    elsif ($esc =~ /&x([0-9]{1,3});/) { $char = chr($1) }
    return $char;
}


sub get_META_info {
    my ($html) = @_;
    $keywords    = ($html =~ s/<meta\s*name=\"?keywords\"?\s*content=\"?([^\"]*)\"?>//is) ? $1 : '';
    $description = ($html =~ s/<meta\s*name=\"?description\"?\s*content=\"?([^\"]*)\"?>//is) ? $1 : '';
    return ($keywords, $description)
}

sub Get_User_Name_by_id {
  my $namebuf;
  if($User_Name_cesh{$_[0]} ne "")
  {
    $namebuf = $User_Name_cesh{$_[0]};
  }
  else
  {
    open (userinfo, "<$base_dir/users/$_[0].txt");
    flock(userinfo, 1);
    @userinfo = <userinfo>;
    close userinfo;
    chomp $userinfo[0];
    $namebuf = $userinfo[0];
    $User_Name_cesh{$_[0]} = $namebuf;
  }
  return "$namebuf";
}

sub getforumname {
  my $thread = $_[0];

  $board = &BoardGet($thread);

  &readindexofboards;

  $forumbuf1 = 0;

  &readindexofthreads;

  return ($threadtitle{$thread});
}

sub BoardGet {
  if(open(boardinfo, "<$base_dir/messages/$_[0]_info.txt"))
  {
    flock(boardinfo, 1);
    $buf = <boardinfo>;
    ($Viewcol, $boardbuf, $ThreadClose, $ThreadHead) = split(/\|/,$buf);
    close(boardinfo);
    return $boardbuf;
  }
  else
  {return -1}
}

sub readindexofboards{
  open(boards, "<$base_dir/boards/boards.txt");
  flock(boards, 1);
  @indexofboards=<boards>;
  close (boards);

  foreach (@indexofboards)
  {
    chomp $_;
    ($typebuf, $visiblebuf, $titlebuf, $idbuf, $commentbuf)=split(/\|/,$_);
    if($typebuf ne 0)
    {
      $commentofboard{$idbuf}=$commentbuf;
      ( $threadcount, $messagecount, $lastposttime, $lastposter ) = &BoardCountGet($idbuf);
      $threadcountofboard{$idbuf} = $threadcount;
      $messagecountofboard{$idbuf} = $messagecount;
      $lastposttimeofboard{$idbuf} = $lastposttime;
    }
    $categoryofboard{$idbuf}=$typebuf;
    $visibleofboard{$idbuf}=$visiblebuf;
    $titleofboard{$idbuf}=$titlebuf;

    $_ = $idbuf;
  }
}

sub readindexofthreads{
  open(threads, "<$base_dir/boards/$board.txt");
  flock(threads, 1);

  $threadnum = 0;
  $threadnum1 = 0;
  while (<threads>)
  {
    if(($threadnum>=$minthread & $threadnum<=$maxthread)|$forumbuf1 eq 0)
    {
      $threadbuf = $_;
      chomp $threadbuf;
      ($idbuf, $typebuf, $titlebuf, $commentbuf, $avtorbuf, $messagecountbuf, $lastposttimebuf, $lastposterbuf)=split(/\|/,$threadbuf);
      $threadtype{$idbuf} = $typebuf;
      if($typebuf eq 2)
      {
        $threadcomment{$idbuf} = "Сценарий: <a href=\"$site?play=$commentbuf\">$site?play=$commentbuf</a>";
      }
      else
      {
        $threadcomment{$idbuf} = $commentbuf;
      }
      $threadtitle{$idbuf} = $titlebuf;
      $threadmessagecount{$idbuf} = $messagecountbuf;
      $threadlastposttime{$idbuf} = $lastposttimebuf;
      $threadlastposter{$idbuf} = $lastposterbuf;
      @indexofthreads[$threadnum1] = $idbuf;
      $threadnum1++;
    }
    $threadnum++;
  }

  close (threads);
}

sub BoardCountGet {
  if(open(boardinfo, "<$base_dir/boards/$_[0]_info.txt") )
  {
    flock(boardinfo, 1);
    $_ = <boardinfo>;
    chomp;
    close(boardinfo);
    return split(/\|/,$_);
  }
  else
  {
    return (0, 0, "<i>Нет информации</i>","")
  }
}

