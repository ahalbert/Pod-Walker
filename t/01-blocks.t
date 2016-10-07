use Test;
use Pod::Walker;
plan 2;

=begin BlockTest
=begin foo 
    Foo
=end foo

=for head1
Foor

=table
  col1  col2
=end BlockTest

=begin FormattingBlockTest
=head1 Bar Lorem ipsum dolor sit amet.

say what
=begin code
this = 1 * code(Nil);
=end code
=begin output
[test@pod ~]? K<y>
=end output
=end FormattingBlockTest

is walk(Pod::Walker, $=pod[0]), q'(((Foo))((Foor)){"" [(col1) (col2)] })';
my $FormattingBlockTestExpected = q<(((Bar Lorem ipsum dolor sit amet.))(say what)(this = 1 * code(Nil);
)(([test@pod ~]? (y))))>;
is walk(Pod::Walker, $=pod[1]), $FormattingBlockTestExpected;
