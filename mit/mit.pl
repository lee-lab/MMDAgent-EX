#!/usr/bin/perl


my $root = ".";
my $contentfilelist = $root . "/.mmdagent-content-files";

######################################################################
my %content;
my $contentTime;

open(DATA, $contentfilelist);
$contentTime = <DATA>;
while(<DATA>) {
    chomp;
    $p = index($_, " ");
    $s = substr($_, 0, $p);
    $f = substr($_, $p);
    $f =~ s/^ *//g;
    $content{$f} = $s;
}
close(DATA);
 
my $filelist = &get_files($root);
my %filesize;

my @nochange;
my @update;
my @untracked;

foreach (@$filelist){
    my $size = -s $_;

    next if (/ContentFileList$/);

    s/^$root\///g;

    next if (/^$/);

#    print "$size $_\n";

    $filesize{$_} = $size;

    if (exists($content{$_})) {
	if ($content{$_} != $size) {
#	    print "[update] $size $_\n";
	    push(@update, $_);
	} else {
	    push(@nochange, $_);
	}
    } else {
#	print "[new] $size $_\n";
	push(@untracked, $_);
    }
}

foreach (keys %content) {
    $d = $_;
    next if (/^$/);
    if (! grep {$_ eq $d} @$filelist) {
	push(@missing, $d);
    }
}

######################################################################
if ($#ARGV < 0 || $ARGV[0] eq "status") {
    $hasone = 0;
    # no argument
    if ($#update >= 0) {
	print "  [updated] --- do 'mit update' to update them\n";
	foreach (@update) {
	    print "\t$_ " . $content{$_} . " -> " . $filesize{$_} . "\n";
	}
	print "\n";
	$hasone = 1;
    }
    if ($#missing >= 0) {
	print "  [missing] --- do 'mit delete' to delete them from list\n";
	foreach (@missing) {
	    print "\t$_\n";
	}
	print "\n";
	$hasone = 1;
    }
    if ($#untracked >= 0) {
	print "  [untracked] -- do 'mit add' to add them to list\n";
	foreach (@untracked) {
	    print "\t$_\n";
	}
	print "\n";
	$hasone = 1;
    }
    if ($hasone == 0) {
	print "clean, up-to-date!\n";
    }

} elsif ($ARGV[0] eq "update") {
    # update
    foreach (@update) {
	$content{$_} = $filesize{$_};
	print "updating $_\n";
    }
    open(DATA, ">$contentfilelist");
    print DATA time() . "\n";
    foreach (keys %content) {
	$d = $_;
	next if (/^$/);
	print DATA $content{$_} . " " . $_ . "\n";
    }
    close(DATA);
    print "updated $contentfilelist\n";
} elsif ($ARGV[0] eq "delete") {
    # delete
    foreach (@missing) {
	print "deleting $_\n";
	delete($content{$_});
    }
    open(DATA, ">$contentfilelist");
    print DATA time() . "\n";
    foreach (keys %content) {
	$d = $_;
	next if (/^$/);
	print DATA $content{$_} . " " . $_ . "\n";
    }
    close(DATA);
    print "delete missing files from $contentfilelist\n";
} elsif ($ARGV[0] eq "add") {
    # add
    foreach (@untracked) {
	print "adding $_\n";
	$content{$_} = $filesize{$_};
    }
    open(DATA, ">$contentfilelist");
    print DATA time() . "\n";
    foreach (keys %content) {
	$d = $_;
	next if (/^$/);
	print DATA $content{$_} . " " . $_ . "\n";
    }
    close(DATA);
    print "untracked files are added to $contentfilelist\n";
} elsif ($ARGV[0] eq "create") {
    # create
    open(DATA, ">$contentfilelist");
    print DATA time() . "\n";
    foreach (keys %filesize) {
	$d = $_;
	next if (/^$/);
	print DATA $filesize{$_} . " " . $_ . "\n";
    }
    close(DATA);
    print "$contentfilelist all updated\n";
} else {
    print STDERR "usage: mit {status|update|delete|add|create}\n";
}

sub get_files {
    my $dir = shift;
    my $filelist = shift;
    opendir (DIR, "$dir");
    my @list = grep /^[^\.]/, readdir DIR;
    closedir DIR;
    foreach my $file (@list) {
        if (-d "$dir/$file"){
            $filelist = &get_files("$dir/$file", $filelist);
        } else {
            push @$filelist, "$dir/$file";
        }
    }
    return $filelist;
}
