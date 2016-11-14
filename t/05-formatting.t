use Pod::Walker;
use Test;
plan 4;
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
#3
=begin AliasTest
=alias PROGNAME    Earl Irradiatem Eventually
=alias VENDOR      4D Kingdoms
=alias TERMS_URL   L<http://www.4dk.com/eie>

The use of A<PME> is subject to the terms and conditions
laid out by A<VENDOR>, as specified at A<TERMS_URL>.

=end AliasTest
my Str $aliasTestResult = "((The use of A(PME) is subject to the terms and conditions laid out by (4D Kingdoms), as specified at ((()<http://www.4dk.com/eie>)).))";

is walk(Pod::Walker, $=pod[0]), "((B<or not B>))";
is walk(Pod::Walker, $=pod[1]), "((((http://www.google.com)<MP3>)))";
is walk(Pod::Walker, $=pod[2]), "(((This is a test of the P formatting code.)))";
is walk(Pod::Walker, $=pod[3]), $aliasTestResult;
