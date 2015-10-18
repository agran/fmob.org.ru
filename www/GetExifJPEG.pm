use Exporter();

sub getexifjpeg;

    my %rc;              # r: hash to return
    my $intelAlignment = 0;        # byte alignment - read from EXIF header
    my $debug = 0;                        # output debug info
# EXIF tag maps
my %tagid = (
             0x10e  => "ImageDescription",
             0x10f  => "Make",
             0x110  => "Model",
             0x112  => "Orientation",
             0x11a  => "XResolution",
             0x11b  => "YResolution",
             0x128  => "ResolutionUnit",
             0x131  => "Software",
             0x132  => "DateTime",
             0x13B  => "Artist",             # added by cap
             0x213  => "YCbCrPositioning",
             0x8769 => "EXIFOffset",
             0x103  => "Compression",
             0x201  => "JPEGInterchangeFormat",
             0x202  => "JPEGInterchangeFormatLength",
             0x829A => "ExposureTime",
             0x829D => "FNumber",
             0x8769 => "EXIFSubIFD",
             0x8822 => "ExposureProgram",
             0x8827 => "ISOSpeedRating",
             0x9000 => "EXIFVersion",
             0x9003 => "DateTimeOriginal",
             0x9004 => "DateTimeDigitized",
             0x9101 => "ComponentsConfiguration",
             0x9102 => "CompressedBitsPerPixel",
             0x9204 => "ExposureBiasValue",
             0x9205 => "MaxApertureValue",
             0x9207 => "MeteringMode",
             0x9208 => "LightSource",
             0x9209 => "Flash",
             0x920A => "FocalLength",
             0x927c => "MakerNote",
             0x9286 => "UserComment",
             0xA000 => "FlashPixVersion",
             0xA001 => "ColorSpace",
             0xA002 => "EXIFImageWidth",
             0xA003 => "EXIFImageLength",
             0xA005 => "InteroperabilityOffset",
             0xA300 => "FileSource",
             0xA301 => "SceneType",
             0xA401 => "CustomRendered",
             0xA402 => "ExposureMode",
             0xA403 => "WhiteBalance",
             0xA404 => "DigitalZoomRatio",
             0xA405 => "FocalLength35",
             0xA406 => "SceneCaptureType",
             0xA407 => "GainControl",
             0xA408 => "Contrast",
             0xA409 => "Saturation",
             0xA40a => "Sharpness",
             0xA40c => "SubjectDistanceRange",
# cap: tags which were Unrecognised but exist in Exif 2.2
             0xA217 => "SensingMethod",
             0xA215 => "ExposureIndex",
             0x9201 => "ShutterSpeedValue", # Shutter speed. The unit is the APEX setting (see Annex C).
             0x9202 => "ApertureValue", # The lens aperture. The unit is the APEX value.
# cap: tags for info written by Windows Explorer (file properties)
             0x9c9b => "Title",
             0x9c9d => "Author",
             0x9c9f => "Subject",
             0x9c9e => "Keywords",
             0x9c9c => "Comments",
            );



#---------------------------------------------------------------
# getexifjpeg()
# Getting information about JPEG stored in Exif by Windows Explorer
# NB: this routine significantly re-uses code of exif.pl script
#     written by Martin Krzywinski (martink@bcgsc.ca)
#---------------------------------------------------------------
# i: $_[0] pathname of the file
# r: associative array of file info:
#    'error_code' ne "" Explanation of an error, other members of array are meaningless
#                 eq "" No error, other members of array caontain valid info
sub getexifjpeg
{
    my $fname = $_[0];   # i: pathname of file
    my $exif_cnt = 0;     # l: counter of Exif blocks found in the file

# markers are FFXX where XX is one of those below
my %jpeg_markers = (
                    SOF         => chr(0xc0), #
                    DHT         => chr(0xc4), # Define Huffman table
                    SOI         => chr(0xd8), # Start of image
                    EOI         => chr(0xd9), # End of image
                    SOS         => chr(0xda), #
                    DQT         => chr(0xdb), # Define quantisation table
                    DRI         => chr(0xdd), # Define quantisation table
                    APP1 => chr(0xe1), # APP1 - where EXIF data is stored
                   );

# Once a tag is parsed, you can get the value with $tagvalues{TEXT} where TEXT is
# the text-value of a tag in the %coolpixtags and %tagid hashes.

my %tagvalues;

# NB: cap - remove all items from hash!!!
    foreach $key (keys %rc) {
        delete $rc{$key};
    }



    debug( $fname );
# open file
    open ( IN, $fname ) or  return ( 'error_code' => "Error: open() of ".$fname." failed" );
# set binary mode
    binmode( IN ) or return ( 'error_code' => "Error: binmode() of ".$fname." failed" );
# look for APP1 with Exif
while (!eof(IN)) {
  # JPEG file is made up of blocks which start with a
  # 2 byte marker: 0xff, marker
  my $ch;
  if (! read(IN,$ch,1)) {
    debug("end of file reached");
    return ( 'error_code' => "Error: end of ".$fname." reached" );
  }

  # image data doesn't start with 0xff
  if(ord($ch) != 0xff) {
    debug("! 0xff - last");
    last;
  }
  my $marker;
  if(! read(IN,$marker,1)) {
    debug("end of file reached while reading marker");
    return ( 'error_code' => "Error: end of ".$fname." reached while reading marker" );
  }
# for debug show offset of APP1 in decimal
  debug (tell(IN));
  if ($marker eq $jpeg_markers{SOI}) {
    debug("[M] SOI");
  } elsif ($marker eq $jpeg_markers{EOI}) {
    debug("[M] EOI");
  } else {

    my ($msb, $lsb, $data, $size);

    # Markers other than SOI and EOI have associated data
    # next 2 bytes are the length of this block (including themselves)
    return ( 'error_code' => "Error reading length of msb of marker in ".$fname ) if !read(IN, $msb, 1);
    return ( 'error_code' => "Error reading length of lsb of marker in ".$fname ) if !read(IN, $lsb, 1);
    $size = 256 * ord($msb) + ord($lsb);

    # remainder of the block is size - 2 bytes long
    return ( 'error_code' => "File ".$fname." truncated" ) if read(IN, $data, $size - 2) != $size - 2;

    if ($marker eq $jpeg_markers{APP1}) {
      # APP1 block contains the EXIF data
      debug("[M] APP1: $size bytes");

      debug("Try to get Exif from APP1");

# Extracting Exif data if any

    # first 6 bytes should be the EXIF header: 'Exif\0\0'
    my $header = substr($data, 0, 6);
### die "APP1 does not contain EXIF data\n" if ($header ne "Exif\0\0");
# if this APP1 does not contain Exif data, continue to scan the file
      next if ($header ne "Exif\0\0");

# this APP1 conatins Exif
    debug("Reading EXIF data");
      $exif_cnt++;     # increment Exif counter
    $data = substr($data, 6);

# check TIFF header: Byte align/TAG/Offset to first IFD
    if (substr($data, 0, 2) eq 'II') {
      debug("Intel byte alignment");
      $intelAlignment = 1;
    } elsif (substr($data, 0, 2) eq 'MM') {
      debug("Motorola byte alignment");
      $intelAlignment = 0;
    } else {
      return ('error_code'=>"Invalid byte alignment (no Intel nor Motorola) in TIFF header of ".$fname."\n");
    }

    # check EXIF tag (0x002a)
    debug ("Invalid tag mark") if readShort($data, 2) != 0x002a;

    # read offset to first IFD
    my $offset = readLong($data, 4);
    debug("Offset to first IFD: $offset");

    # first 2 bytes of IFD define the number of 12-byte entries
    my $numEntries = readShort($data, $offset);
    $offset += 2;
    debug("Number of directory entries: $numEntries");

    my $i;
    for ($i = 0; $i < $numEntries; $i++) {
      # Each entry is made up of 12 bytes
      # Tag (2 bytes)
      # Format (2 bytes)
      # Num components (4 bytes)
      # Data or offset to data if longer than 4 bytes (4 bytes)
      my $entry = substr($data, $offset + 12 * $i, 12);
      my $tag = readShort($entry, 0);
      my $format = readShort($entry, 2);
      my $components = readLong($entry, 4);
      my $offset = readLong($entry, 8);

      # Read the value using the appropriate format
      my $value =        readIFDEntry($data, $format, $components, $offset,$entry);

      # Decode individual EXIF tags
      debug(sprintf("0x%X\n",$tag));
      if($tagid{$tag}) {
        # Deal with special tags
        if($tagid{$tag} eq "EXIFSubIFD") {
          exifSubIFD($data, $offset);
        } elsif ($tagid{$tag} eq "MakerNote") {

        } else {
          reporttag($tag,$format,$components,$offset,$value);
          $tagvalues{$tagid{$tag}} = $value;
        }
      } else {
        debug(sprintf("Unrecognised entry: TAG=0x%x, $value\n", $tag));
      }
### cap: addchecking  individual tags
      if ($tag == 0x10e) {
         debug(sprintf("Image Description: TAG=0x%x, $value\n", $tag));
      }
    }
    $offset = readLong($data, $offset + 12 * $numEntries);
    debug("Offset to next IFD: $offset");

# end of processing Exif data
    } elsif ($marker eq $jpeg_markers{DQT}) {
      debug("[M]  DQT: $size bytes");
    } elsif ($marker eq $jpeg_markers{SOF0}) {
      debug("[M] SOF0: $size bytes");
    } elsif ($marker eq $jpeg_markers{DHT}) {
      debug("[M]  DHT: $size bytes");
    } elsif ($marker eq $jpeg_markers{SOS}) {
      debug("[M] SOSh: $size bytes");
    } else {
      debug(sprintf("Unknown marker: 0x%04x, size: $size\n", $marker));
    }
  }
}
# check for Exif counter
    if ($exif_cnt == 0) { return ('error_code'=>"No Exif data in ".$fname."\n" ); }
# close file
    close IN;
# successful return
    $rc{'error_code'} = "";
    $rc{'filename'} = $fname;
    return %rc;
}



# Extract EXIF sub IFD info
sub exifSubIFD  {

  my ($data, $offset) = @_;
  debug("EXIF: offset=$offset");

    # IFD starts with the number of entries
    my $numEntries = readShort($data, $offset);
    $offset += 2;
    debug("Number of directory entries: $numEntries");

    # Read the 12-byte long entries
    my $i;
    for ($i = 0; $i < $numEntries; $i++) {
      my $entry = substr($data, $offset + 12 * $i, 12);
      my $tag = readShort($entry, 0);
      my $format = readShort($entry, 2);
      my $components = readLong($entry, 4);
      my $offset = readLong($entry, 8);

      my $value =        readIFDEntry($data, $format, $components, $offset, $entry);

      if($tagid{$tag}) {
        if($tagid{$tag} eq "MakerNote") {
###cap          makerNote($data, $offset);
            debug("Call MakerNote");
        } else {
          reporttag($tag,$format,$components,$offset,$value);
        }
      } else {
        debug(sprintf("Unrecognised entry: TAG=0x%x, $value\n", $tag));
      }
    }
}

# read 2-byte short, byte aligned according to $intelAlignment
sub readShort
  {
    my ($data, $offset) = @_;
    die "readShort: end of string reached" if length($data) < $offset + 2;
    my $ch1 = ord(substr($data, $offset++, 1));
    my $ch2 = ord(substr($data, $offset++, 1));
    if ($intelAlignment) {
      return $ch1 + 256 * $ch2;
    }
    return $ch2 + 256 * $ch1;
  }

# read 4-byte long, byte aligned according to $intelAlignment
sub readLong
  {
    my ($data, $offset) = @_;
    die "readLong: end of string reached" if length($data) < $offset + 4;
    my $ch1 = ord(substr($data, $offset++, 1));
    my $ch2 = ord(substr($data, $offset++, 1));
    my $ch3 = ord(substr($data, $offset++, 1));
    my $ch4 = ord(substr($data, $offset++, 1));
    if ($intelAlignment) {
      return (((($ch4 * 256) + $ch3) * 256) + $ch2) * 256 + $ch1;
    }
    return (((($ch1 * 256) + $ch2) * 256) + $ch3) * 256 + $ch4;
  }

# read formatted IFD entry
sub readIFDEntry
  {
    my ($data, $format, $components, $offset, $entry) = @_;
# cap: check for Windows tags:
    my $tag = readShort($entry, 0);
    if ((($tagid{$tag} eq "Title")
       ||($tagid{$tag} eq "Author")
       ||($tagid{$tag} eq "Subject")
       ||($tagid{$tag} eq "Keywords")
       ||($tagid{$tag} eq "Comments")
         )
       && ($format == 1) # BYTE
         ){
        debug("readIFDEntry: Windows tag '".$tagid{$tag}."'");
# get unicode string
        debug("Unicode string: offset:".$offset." components: ".$components);
        my $value="";
        my $unichr;
        my $len=$components/2;
        for ($i=0; $i<$len; $i++) {
# get unicode char
            $unichr = readShort($data,$offset);
            debug( sprintf("unichr: 0x%X",$unichr));
# translate unicode to win1251
            $value .= unicode_win1251( $unichr );
# move pointer to the next unicode char
                   $offset += 2;
        }
###        $unicode = readShort($data,$offset);
###         printf("First Word Of Unicode: 0x%X\n", $unicode );
        debug( $value );
        return $value;
    }

    if ($format == 2) {
      # ASCII string
        debug("ASCII string: offset:".$offset." components: ".$components);
      my $value = substr($data, $offset, $components);
      $value =~ s/\0+$//;        # remove trailing NULL chars
      return $value;
    } elsif ($format == 3) {
      if($components == 2) {
        # two components and a short int - probably a pair of values
        #printhex($entry);
        my $v1 = readShort($entry,8,2);
        my $v2 = readShort($entry,10,2);
        return "$v1,$v2";
      }
      # Unsigned short
      if (!$intelAlignment) {
        $offset = 0xffff & ($offset >> 16);
      }
      return $offset;
    } elsif ($format == 4) {
      # Unsigned long
      return $offset;
    } elsif ($format == 5) {
      # Unsigned rational
      my $numerator = readLong($data, $offset);
      my $denominator = readLong($data, $offset + 4);
      #print "$numerator / $denominator\n";
      if($denominator) {
        return "$numerator/$denominator";
      }
    } elsif ($format == 10) {
      # Signed rational
      my $numerator = readLong($data, $offset);
      $numerator -= 2 ** 32 if ($numerator > 2 ** 31);
      my $denominator = readLong($data, $offset + 4);
      #print "$numerator / $denominator\n";
      if($denominator) {
        return "$numerator/$denominator";
      }
    } elsif ($format ==7) {
      if($components == 4) {
        # if the format is 7 (undefined) and there are 4 components,
        # return the chr values of the offset data field - hoping
        # that these are useful data values
        #
        # for example, 0x0088 is 'AF Focus Position' and its values
        # are
        #
        # 00 00 00 00 center
        # 00 01 00 00 top
        # 00 02 00 00 bottom, etc.
        # printhex($entry);
        my @v = unpack("c*",substr($entry,8,4));
        return join(",",@v);
      }
      return $offset;
    } elsif ($format ==8) {
      # signed short
      return $offset;
    } else {
      return 0;
    }
  }


sub reporttag {
  my ($tag,$format,$components,$offset,$value,$tagidhash) = @_;
  if(! $tagidhash) {
    $tagidhash = \%tagid;
  }
  if($tagidhash->{$tag} ne "UNKNOWN") {
    debug(sprintf ("TAGINFO %04X %2d %3d %30s %s\n",$tag,$format,$components,$tagidhash->{$tag},$value));
    $rc{$tagidhash->{$tag}} = $value;
    debug(sprintf("%s %s\n",$tagidhash->{$tag}, $rc{'$tagidhash->{$tag}'}));
###    print %rc;
  }
}

### Unicode to Windows 1251(Cyrillic)
sub unicode_win1251 {
    my ($unichr)=@_;
    debug (sprintf("0x%X",$unichr));
    if ( $unichr == 0 ) {
        return "";
    }
    if ( $unichr < 0x80 ) {
        return chr($unichr);
    }
    else {
#        my %uni2win1251 = (
#                    0x041C => 0xCC, # 'Ì'
#                    0x0430 => 0xE0, # 'à'
#                    0x043a => 0xEA, # 'ê'
#                    0x0441 => 0xF1, # 'c'
#                    0x0438 => 0xE8, # 'è'
#                    0x043C => 0xEC, # 'ì'
#                   );

# Unicode->Win1251 Replacement Table for Perl Generated by Win1251<->UTF-8 Generator for PHP and Python
my %uni2win1251=(
0x402 => 0x80, # Cyrillic Capital Letter Dje
0x403 => 0x81, # Cyrillic Capital Letter Gje
0x201A => 0x82, # Single Low-9 Quotation Mark
0x453 => 0x83, # Cyrillic Small Letter Gje
0x201E => 0x84, # Double Low-9 Quotation Mark
0x2026 => 0x85, # Horizontal Ellipsis
0x2020 => 0x86, # Dagger
0x2021 => 0x87, # Double Dagger
0x20AC => 0x88, # Euro Sign
0x2030 => 0x89, # Per Mille Sign
0x409 => 0x8A, # Cyrillic Capital Letter Lje
0x2039 => 0x8B, # Single Left-Pointing Angle-Quotation Mark
0x40A => 0x8C, # Cyrillic Capital Letter Nje
0x40C => 0x8D, # Cyrillic Capital Letter Kje
0x40B => 0x8E, # Cyrillic Capital Letter Tshe
0x40F => 0x8F, # Cyrillic Capital Letter Dzhe
0x452 => 0x90, # Cyrillic Small Letter Dje
0x2018 => 0x91, # Left Single Quotation Mark
0x2019 => 0x92, # Right Single Quotation Mark
0x201C => 0x93, # Left Double Quotation Mark
0x201D => 0x94, # Right Double Quotation Mark
0x2022 => 0x95, # Bullet
0x2013 => 0x96, # En Dash
0x2014 => 0x97, # Em Dash
0x3F => 0x98, # Question Mark for undefined win1251 code
0x2122 => 0x99, # Trade Mark
0x459 => 0x9A, # Cyrillic Small Letter Lje
0x203A => 0x9B, # Single Right-Pointing Angle-Quotation Mark
0x45A => 0x9C, # Cyrillic Small Letter Nje
0x45C => 0x9D, # Cyrillic Small Letter Kje
0x45B => 0x9E, # Cyrillic Small Letter Tshe
0x45F => 0x9F, # Cyrillic Small Letter Dzhe
0xA0 => 0xA0, # No-Break Space
0x40E => 0xA1, # Cyrillic Capital Letter Short U
0x45E => 0xA2, # Cyrillic Small Letter Short U
0x408 => 0xA3, # Cyrillic Capital Letter Je
0xA4 => 0xA4, # Currency Sign
0x490 => 0xA5, # Cyrillic Capital Letter Ghe With Upturn
0xA6 => 0xA6, # Broken Bar
0xA7 => 0xA7, # Section Sign
0x401 => 0xA8, # Cyrillic Capital Letter Io
0xA9 => 0xA9, # Copyright Sign
0x404 => 0xAA, # Cyrillic Capital Letter Ukrainian Ie
0xAB => 0xAB, # Left-Pointing Double Angle Quotation Mark
0xAC => 0xAC, # Not Sign
0xAD => 0xAD, # Soft Hyphen
0xAE => 0xAE, # Registered Sign
0x407 => 0xAF, # Cyrillic Capital Letter Yi
0xB0 => 0xB0, # Degree Sign
0xB1 => 0xB1, # Plus-Minus Sign
0x406 => 0xB2, # Cyrillic Capital Letter Byelorussian-Ukrainian I
0x456 => 0xB3, # Cyrillic Small Letter Byelorussian-Ukrainian I
0x491 => 0xB4, # Cyrillic Small Letter Ghe With Upturn
0xB5 => 0xB5, # Micro Sign
0xB6 => 0xB6, # Pilcrow Sign
0xB7 => 0xB7, # Middle Dot
0x451 => 0xB8, # Cyrillic Small Letter Io
0x2116 => 0xB9, # Numero Sign
0x454 => 0xBA, # Cyrillic Small Letter Ukrainian Ie
0xBB => 0xBB, # Right-Pointing Double Angle Quotation Mark
0x458 => 0xBC, # Cyrillic Small Letter Je
0x405 => 0xBD, # Cyrillic Capital Letter Dze
0x455 => 0xBE, # Cyrillic Small Letter Dze
0x457 => 0xBF, # Cyrillic Small Letter Yi
0x410 => 0xC0, # Cyrillic Capital Letter A
0x411 => 0xC1, # Cyrillic Capital Letter Be
0x412 => 0xC2, # Cyrillic Capital Letter Ve
0x413 => 0xC3, # Cyrillic Capital Letter Ghe
0x414 => 0xC4, # Cyrillic Capital Letter De
0x415 => 0xC5, # Cyrillic Capital Letter Ie
0x416 => 0xC6, # Cyrillic Capital Letter Zhe
0x417 => 0xC7, # Cyrillic Capital Letter Ze
0x418 => 0xC8, # Cyrillic Capital Letter I
0x419 => 0xC9, # Cyrillic Capital Letter Short I
0x41A => 0xCA, # Cyrillic Capital Letter Ka
0x41B => 0xCB, # Cyrillic Capital Letter El
0x41C => 0xCC, # Cyrillic Capital Letter Em
0x41D => 0xCD, # Cyrillic Capital Letter En
0x41E => 0xCE, # Cyrillic Capital Letter O
0x41F => 0xCF, # Cyrillic Capital Letter Pe
0x420 => 0xD0, # Cyrillic Capital Letter Er
0x421 => 0xD1, # Cyrillic Capital Letter Es
0x422 => 0xD2, # Cyrillic Capital Letter Te
0x423 => 0xD3, # Cyrillic Capital Letter U
0x424 => 0xD4, # Cyrillic Capital Letter Ef
0x425 => 0xD5, # Cyrillic Capital Letter Ha
0x426 => 0xD6, # Cyrillic Capital Letter Tse
0x427 => 0xD7, # Cyrillic Capital Letter Che
0x428 => 0xD8, # Cyrillic Capital Letter Sha
0x429 => 0xD9, # Cyrillic Capital Letter Shcha
0x42A => 0xDA, # Cyrillic Capital Letter Hard Sign
0x42B => 0xDB, # Cyrillic Capital Letter Yeru
0x42C => 0xDC, # Cyrillic Capital Letter Soft Sign
0x42D => 0xDD, # Cyrillic Capital Letter E
0x42E => 0xDE, # Cyrillic Capital Letter Yu
0x42F => 0xDF, # Cyrillic Capital Letter Ya
0x430 => 0xE0, # Cyrillic Small Letter A
0x431 => 0xE1, # Cyrillic Small Letter Be
0x432 => 0xE2, # Cyrillic Small Letter Ve
0x433 => 0xE3, # Cyrillic Small Letter Ghe
0x434 => 0xE4, # Cyrillic Small Letter De
0x435 => 0xE5, # Cyrillic Small Letter Ie
0x436 => 0xE6, # Cyrillic Small Letter Zhe
0x437 => 0xE7, # Cyrillic Small Letter Ze
0x438 => 0xE8, # Cyrillic Small Letter I
0x439 => 0xE9, # Cyrillic Small Letter Short I
0x43A => 0xEA, # Cyrillic Small Letter Ka
0x43B => 0xEB, # Cyrillic Small Letter El
0x43C => 0xEC, # Cyrillic Small Letter Em
0x43D => 0xED, # Cyrillic Small Letter En
0x43E => 0xEE, # Cyrillic Small Letter O
0x43F => 0xEF, # Cyrillic Small Letter Pe
0x440 => 0xF0, # Cyrillic Small Letter Er
0x441 => 0xF1, # Cyrillic Small Letter Es
0x442 => 0xF2, # Cyrillic Small Letter Te
0x443 => 0xF3, # Cyrillic Small Letter U
0x444 => 0xF4, # Cyrillic Small Letter Ef
0x445 => 0xF5, # Cyrillic Small Letter Ha
0x446 => 0xF6, # Cyrillic Small Letter Tse
0x447 => 0xF7, # Cyrillic Small Letter Che
0x448 => 0xF8, # Cyrillic Small Letter Sha
0x449 => 0xF9, # Cyrillic Small Letter Shcha
0x44A => 0xFA, # Cyrillic Small Letter Hard Sign
0x44B => 0xFB, # Cyrillic Small Letter Yeru
0x44C => 0xFC, # Cyrillic Small Letter Soft Sign
0x44D => 0xFD, # Cyrillic Small Letter E
0x44E => 0xFE, # Cyrillic Small Letter Yu
0x44F => 0xFF, # Cyrillic Small Letter Ya
    ); # %uni2win1251


        if ($uni2win1251{$unichr}) {
            return chr($uni2win1251{$unichr});
        }
        else {
            return "?";
        }
    }
} # unicode_win1251()

### debugging functions

sub printhex {
  my $data = shift;
  my @hex;
  my @ascii;
  foreach (0..length($data)) {
    my $bytevalue = substr($data,$_,1);
    push(@hex,unpack("H*",$bytevalue));
    push(@ascii,$bytevalue);
  }
  print join(" ",map(chr,@hex));
  foreach (@ascii) {
    if(ord($_) > 21 && ord($_) < 128) {
      print $_;
    } else {
      print ".";
    }
  }
  print "\n";
}

sub debug {
  print "@_\n" if $debug;
}


1;
