use warnings;
use strict;

use Test::More tests => 14;

BEGIN { $^H |= 0x20000; }

ok eval("if(0) { foo(); } 1");
ok !eval("use Sub::StrictDecl; if(0) { foo(); } 1");
ok eval("if(0) { foo(); } 1");
ok eval("{ use Sub::StrictDecl; } if(0) { foo(); } 1");
ok eval("use Sub::StrictDecl; no Sub::StrictDecl; if(0) { foo(); } 1");
ok !eval("use Sub::StrictDecl; { no Sub::StrictDecl; } if(0) { foo(); } 1");

SKIP: {
	skip "lexical hints don't propagate into eval on this perl", 7
		unless "$]" >= 5.009003;
	ok eval("if(0) { foo(); } 1");
	use Sub::StrictDecl;
	ok !eval("if(0) { foo(); } 1");
	{
		ok !eval("if(0) { foo(); } 1");
		ok eval("no Sub::StrictDecl; if(0) { foo(); } 1");
		ok !eval("if(0) { foo(); } 1");
		no Sub::StrictDecl;
		ok eval("if(0) { foo(); } 1");
	}
	ok !eval("if(0) { foo(); } 1");
}

{
	use Sub::StrictDecl;
	require t::scope_0;
	ok 1;
}

1;
