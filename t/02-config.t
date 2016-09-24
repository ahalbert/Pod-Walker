use Test;
use Pod::Walker;
plan 4;

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

is walk(Pod::Walker, $=pod[0]).gist, "((Bar))";
is walk(Pod::Walker, $=pod[1]).gist, "(((((Bar)))))";
is walk(Pod::Walker, $=pod[2]).gist, "((Bar))";
is walk(Pod::Walker, $=pod[3]).gist, "(((Bar)))";

