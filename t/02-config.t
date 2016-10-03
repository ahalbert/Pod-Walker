#TODO
#:allow
#:margin
use Test;
use Pod::Walker;
plan 9;
#0
=begin para :formatted<B>
    Bar
=end para
#1
=begin para :formatted<B I C A>
    Bar
=end para
#2
=begin para :nested
    Bar
=end para
#3
=begin para :nested(2)
    Bar
=end para
#4
=begin para :nested(0)
    Bar
=end para
#5
=begin Numberedtest
=for head1 :numbered
The Problem

=for head1 :numbered
The Solution

    =for head2 :numbered
    Analysis
=end Numberedtest
#6
=begin Configtest
=config head1  :formatted<B U>  :numbered
=config head2  :formatted<I>

=head1 Bar
    =head2 Baz
=end Configtest
#7
=begin Liketest
=config head1  :formatted<B U>  :numbered
=config head2  :like<head1>

=head1 Bar
    =head2 Baz
        =for head3 :like<head1> 
        Buzz
=end Liketest
#8
=begin PoundNumberTest
    =item1 # Liberty
    =item1 # Death
    =item1 # Beer

    The tools are:

    =item1 # Revolution
    =item1 # Deep-fried peanut butter sandwich
    =item1 # Keg
=end PoundNumberTest

is walk(Pod::Walker, $=pod[0]), "(((Bar)))";
is walk(Pod::Walker, $=pod[1]), "((((((Bar))))))";
is walk(Pod::Walker, $=pod[2]), "((Bar))";
is walk(Pod::Walker, $=pod[3]), "(((Bar)))";
is walk(Pod::Walker, $=pod[4]), "((Bar))";
is walk(Pod::Walker, $=pod[5]), "(((1)(The Problem))((2)(The Solution))((2.1)(Analysis)))";
is walk(Pod::Walker, $=pod[6]), "(((1)(((Bar))))(((Baz))))";
is walk(Pod::Walker, $=pod[7]), "(((1)(((((Bar))))))((1.1)(((Baz))))((1.1.1)(((Buzz)))))";
is walk(Pod::Walker, $=pod[8]), "(((1)(Liberty))((2)(Death))((3)(Beer))(The tools are:)((4)(Revolution))((5)(Deep-fried peanut butter sandwich))((6)(Keg)))";
