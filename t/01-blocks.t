use Test;
use Pod::Walker;
plan 3;

=begin BlockTest
=comment commentedout
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

=begin SemanticBlockTest
=begin SYNOPSIS
    use Magic::Parser;
    my Magic::Parser $parser .= new();
    my $tree = $parser.parse($fh);
B<I shall say this loudly>
    Z<and repeatedly>
and with emphasis.
=end SYNOPSIS
=end SemanticBlockTest

is walk(Pod::Walker, $=pod[0]), q'(((Foo))((Foor)){"" [(col1) (col2)] })';
my $FormattingBlockTestExpected = q<(((Bar Lorem ipsum dolor sit amet.))(say what)C<this = 1 * code(Nil);
>(([test@pod ~]? K<y>)))>;
is walk(Pod::Walker, $=pod[1]), $FormattingBlockTestExpected;
my $SemanticBlockTestExpected = q[(((SYNOPSIS) (C<use Magic::Parser;
my Magic::Parser $parser .= new();
my $tree = $parser.parse($fh);>(B<I shall say this loudly> Z<and repeatedly> and with emphasis.))))];
is walk(Pod::Walker, $=pod[2]), $SemanticBlockTestExpected;
