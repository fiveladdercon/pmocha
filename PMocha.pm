package PMocha;
use base qw(Exporter);

@EXPORT = qw(fail assert expect diff describe it xdescribe xit);

my $BOLD    = "\e[1m";
my $RED     = "\e[31m";
my $GREEN   = "\e[32m";
my $YELLOW  = "\e[33m";
my $MAGENTA = "\e[35m";
my $CLEAR   = "\e[0m";

my $PASS    = "✓";	# \x{2713}
my $FAIL    = "✗";	# \x{2717}
my $SKIP    = "?";	# "†";	# \x{2020}

my $LEVEL   = 1;
my $SKIPPED = 0;
my @FAILED;

my $TESTS   = 0;
my $FAILS   = 0;
my $SKIPS   = 0;

#───────────────────────────────────────────────────────────────────────────────────────────────────
# Assertion API
#───────────────────────────────────────────────────────────────────────────────────────────────────

sub fail {
	my $format = shift;
	if (defined $format) {
		my $TAB = "  " x $LEVEL;
		$format = "\t$format\n";
		$format =~ s/\t/${TAB}${RED}>>>>${CLEAR} /g;
		push @FAILED, sprintf($format, @_);
	} else {
		push @FAILED, '';
	}
}

sub assert {
	my $result = shift;
	&fail(@_) unless $result;
}

sub expect {
	my $actual   = shift;
	my $expected = shift;
	my $format   = $expected =~ /\n/ ? "Expected:\n%s\n\tActual:\n%s\n" : "Expected: %s, Actual: %s";
	&assert($actual eq $expected, $format, $expected, $actual);
}

sub diff {
	my $actual   = shift;
	my $expected = shift;
	open(ACTUAL  , ">actual"  ) or die; print ACTUAL   $actual;   close(ACTUAL);
	open(EXPECTED, ">expected") or die; print EXPECTED $expected; close(EXPECTED);
}

#───────────────────────────────────────────────────────────────────────────────────────────────────
# Test Structure API
#───────────────────────────────────────────────────────────────────────────────────────────────────

sub describe {
	my $string   = shift;
	my $callback = shift;
	my $TAB      = "  " x $LEVEL;
	printf("\n") if ($LEVEL == 1);
	printf("${TAB}${BOLD}$string${CLEAR}\n");
	if (defined $callback) {
		$LEVEL++;
		&$callback();
		$LEVEL--;
	}
	&report() if ($LEVEL == 1);
}

sub it {
	my $string   = shift;
	my $callback = shift;
	my $TAB      = "  " x $LEVEL;
	if (defined $callback and not $SKIPPED) {
		@FAILED = ();
		&$callback();
		$TESTS++;
		$FAILS++ if @FAILED;
		$result = @FAILED ? "${RED}${FAIL}" : "${GREEN}${PASS}";
	} else {
		$SKIPS++;
		$result = "${YELLOW}${SKIP}";
	}
	printf("${TAB}${result}${CLEAR} ${string}\n");
	print(join("", @FAILED)) if @FAILED;
	@FAILED = ();
}

sub xdescribe {
	$SKIPPED++;
	describe(@_);
	$SKIPPED--;
}

sub xit {
	$SKIPPED++;
	it(@_);
	$SKIPPED--;	
}

#───────────────────────────────────────────────────────────────────────────────────────────────────
# Private
#───────────────────────────────────────────────────────────────────────────────────────────────────

sub report {
	if (not exists $ENV{PMOCHA_RUN}) {
		$TESTS = ($TESTS == 1) ? "1 test" : "${TESTS} tests";
		$SKIPS = ($SKIPS == 0) ? "" : " ${YELLOW}(${SKIPS} skipped)";
		if ($FAILS) {
			printf("\n  ${RED}${FAIL} ${FAILS} of ${TESTS} failed${SKIPS}\e[0m\n\n");
			exit(0);
		} else {
			printf("\n  ${GREEN}${PASS} ${TESTS} complete${SKIPS}\e[0m\n\n");
			exit(0);
		}
	}
}

sub run {
	$ENV{PMOCHA_RUN} = 1;
	my $TAB = "";
	my @SCRIPTS = @ARGV ? @ARGV : glob("*.mpl");
	foreach my $script (@SCRIPTS) {
		open(PIPE, "perl -I $ENV{PMOCHA} -MPMocha $script |") or die("Can't pipe: $!\n");
		while (<PIPE>) {
			print;
			$SKIPS++ if /[$SKIP]/;
			$TESTS++ if /$PASS/ or /$FAIL/;
			$FAILS++ if /$FAIL/;
			chomp; 
			s/[^ ].*//;
			$TAB = $_;
		}
		close(PIPE);
		if ($?) {
			printf("${TAB}  ${RED}${FAIL}${CLEAR} $script has errors.\n");
			$TESTS++;
			$FAILS++;
		}
	}
	delete $ENV{PMOCHA_RUN};
	&report();
}


1;