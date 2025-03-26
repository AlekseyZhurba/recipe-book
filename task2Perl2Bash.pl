#!/usr/bin/perl
my $file_name;
my @pars_data;
my $str2json = "{\n";
if (@ARGV) {
	$file_name = $ARGV[0];
} else {
	die "enter /path/to/file/name.file AS parameter\n";
}
if (-e $file_name) {
	open my $fh, '<', $file_name or die "can't open '$file_name': $!";
	while (my $row = <$fh>) {
		push @pars_data, $row;
	}
	close $fh;
} else {
	print "file $file_name no found or no exists";
}
for (my $i = 0; $i < scalar @pars_data; $i++) {
	chomp ($pars_data[$i]);
	if ($pars_data[$i] =~ /\[(.+)\], .+/) {
		chomp ($1);
		$str2json .= "	\"testName\":\"" . $1 . "\",\n";
		$str2json .= "	\"tests\":[\n";
	}
	if ($pars_data[$i] =~ /^-{2,}$/) {
		next;
	}
	if ($pars_data[$i] =~ /^(not ok|ok)\s(\d+)\s(\D+\)),\s(\d+\D+)$/) {
		$str2json .= "		{\n			\"name\":$3,\n			\"status\":\"" . (($1 eq "ok") ? "true" : "false") . "\",\n			\"duration\":\"$4\"\n		}";
		if ($pars_data[$i + 1] =~ /^-{2,}$/) {
			$str2json .= "\n	],\n";
		} else {
			$str2json .= ",\n";
		}
	}
	if ($pars_data[$i] =~ /(\d+) \(of 2\) tests passed, (\d+) tests failed, rated as (.+)%, spent (\d+)ms/) {
		$str2json .= "	\"summary\":{\n		\"succes\":$1,\n		\"failed\":$2,\n		\"rating\":$3,\n		\"duration\":\"$4\"\n	}\n}";
	}
}
system ("echo '$str2json' > /home/padavan/output.json");
