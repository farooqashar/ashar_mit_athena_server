#!/usr/bin/perl -w

use strict;
use warnings;

use File::Path 'rmtree';
use feature 'say';

# Fix for hands-on 6
#
# Use APSW instead of built-in sqlite
# because sqlite implicitly will commit
# a lot of things on a machine-to-machine
# basis, without telling us
#
# Additionally, launch two terminals using tmux
# on the same machine, because lord knows the trouble
# students would have with AFS consistency guarantees

unless(-e "$ENV{'HOME'}/.local/bin/pip3"){
	say "installing pip3";
	`curl -sSo get-pip.py https://bootstrap.pypa.io/pip/3.6/get-pip.py`;
	`python3 get-pip.py 2>/dev/null`;

	$ENV{'PATH'} = $ENV{'PATH'}.":$ENV{'HOME'}/.local/bin";
	unlink "get-pip.py";
}

my $wd;
chomp(my $u = `whoami`);

my @zombies = split '\n', `find /dev/shm -type d -name "h6-$u*" 2>/dev/null`;
foreach(@zombies){
	say "getting rid of old directory $_";
	rmtree $_;
}

do{
	my $id = 1 + int rand(696969);
	$wd = "/dev/shm/h6-$u-$id"
}while(-d $wd);

say "using directory $wd";

mkdir $wd, 0700;
chdir $wd;

say "building sqlite";

`pip3 install https://github.com/rogerbinns/apsw/releases/download/3.38.1-r1/apsw-3.38.1-r1.zip \\
	--global-option=fetch --global-option=--all --global-option=build \\
	--global-option=--enable-all-extensions >/dev/null 2>/dev/null`;

say "making your terminal pretty";

`pip3 install termcolor>/dev/null`;

say "installing patched h6.py";
`curl -so h6.py https://web.mit.edu/jaytlang/www/h69.py`;

say "starting tmux";

`tmux new-session -d`;
`tmux send-keys 'python3 h6.py blue' C-m`;
`tmux split-window  -h`;
`tmux send-keys 'python3 h6.py red' C-m`;
exec qw(tmux attach);
