use Test;
use Pod::Walker;

=begin foo 
    Foo
=end foo

=for head1
Foor
=end head1
=table
  col1  col2

is walk(Pod::Walker, $=pod).gist, "((((Foo)) ((Foor)) ((col1 col2))))";
