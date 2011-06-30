use warnings;
use strict;

use Test::More tests => 28;

BEGIN { $^H |= 0x20000; }

my $r;

$r = eval(q{
	use Sub::StrictDecl;
	if(0) { foo0(); }
	1;
});
is $r, undef;
like $@, qr/\AUndeclared subroutine &main::foo0/;

$r = eval(q{
	use Sub::StrictDecl;
	sub foo1;
	if(0) { foo1(); }
	1;
});
is $r, 1;
is $@, "";

$r = eval(q{
	use Sub::StrictDecl;
	sub foo2 ();
	if(0) { foo2(); }
	1;
});
is $r, 1;
is $@, "";

$r = eval(q{
	use Sub::StrictDecl;
	sub foo3 {}
	if(0) { foo3(); }
	1;
});
is $r, 1;
is $@, "";

$r = eval(q{
	use Sub::StrictDecl;
	BEGIN { *foo4 = sub { }; }
	if(0) { foo4(); }
	1;
});
is $r, 1;
is $@, "";

$r = eval(q{
	use Sub::StrictDecl;
	*foo5 = sub { };
	if(0) { foo5(); }
	1;
});
is $r, undef;
like $@, qr/\AUndeclared subroutine &main::foo5/;

$r = eval(q{
	use Sub::StrictDecl;
	if(0) { print \&bar0; }
	1;
});
is $r, undef;
like $@, qr/\AUndeclared subroutine &main::bar0/;

$r = eval(q{
	use Sub::StrictDecl;
	sub bar1;
	if(0) { print \&bar1; }
	1;
});
is $r, 1;
is $@, "";

$r = eval(q{
	use Sub::StrictDecl;
	sub bar2 ();
	if(0) { print \&bar2; }
	1;
});
is $r, 1;
is $@, "";

$r = eval(q{
	use Sub::StrictDecl;
	sub bar3 {}
	if(0) { print \&bar3; }
	1;
});
is $r, 1;
is $@, "";

$r = eval(q{
	use Sub::StrictDecl;
	BEGIN { *bar4 = sub { }; }
	if(0) { print \&bar4; }
	1;
});
is $r, 1;
is $@, "";

$r = eval(q{
	use Sub::StrictDecl;
	*bar5 = sub { };
	if(0) { print \&bar5; }
	1;
});
is $r, undef;
like $@, qr/\AUndeclared subroutine &main::bar5/;

$r = eval(q{
	use Sub::StrictDecl;
	if(0) { Baz::baz0(); }
	1;
});
is $r, undef;
like $@, qr/\AUndeclared subroutine &Baz::baz0/;

$r = eval(q{
	use Sub::StrictDecl;
	sub Baz::baz1;
	if(0) { Baz::baz1(); }
	1;
});
is $r, 1;
is $@, "";

1;
