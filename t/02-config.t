#TODO
#:like
#:allow
#:margin
use Test;
use Pod::Walker;
plan 5;

=begin para :formatted<B>
    Bar
=end para

=begin para :formatted<B I C A>
    Bar
=end para

=begin para :nested
    Bar
=end para

=begin para :nested(2)
    Bar
=end para

=begin para :nested(0)
    Bar
=end para

=begin Foo
=for head1 :numbered
The Problem

=for head1 :numbered
The Solution

    =for head2 :numbered
    Analysis
=end Foo

is walk(Pod::Walker, $=pod[0]).gist, "((Bar))";
is walk(Pod::Walker, $=pod[1]).gist, "(((((Bar)))))";
is walk(Pod::Walker, $=pod[2]).gist, "((Bar))";
is walk(Pod::Walker, $=pod[3]).gist, "(((Bar)))";
is walk(Pod::Walker, $=pod[5]).gist, "((1 (The Problem)) (2 (The Solution)) (2.2 (Analysis)))";

