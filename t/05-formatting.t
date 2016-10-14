use Pod::Walker;
use Test;
plan 3;
#0
=begin GenericCodeTest
    B<or not B>
=end GenericCodeTest
#1
=begin LCodeTest
L<MP3|http://www.google.com>
=end LCodeTest
#2
=begin PCodeTest
P<file:t/Ptestfile>
=end PCodeTest

is walk(Pod::Walker, $=pod[0]), "((B<or not B>))";
is walk(Pod::Walker, $=pod[1]), "((((http://www.google.com)<MP3>)))";
is walk(Pod::Walker, $=pod[2]), "(((This is a test of the P formatting code.)))";
