#TODO
#:allow
#:margin
use Test;
use Pod::Walker;
plan 7;

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

=begin Foo2
=config head1  :formatted<B U>  :numbered
=config head2  :formatted<I>

=head1 Bar
    =head2 Baz
=end Foo2


=begin Liketest
=config head1  :formatted<B U>  :numbered
=config head2  :like<head1>

=head1 Bar
    =head2 Baz
        =for head3 :like<head1> 
        Buzz
=end Liketest

is walk(Pod::Walker, $=pod[0]).gist, "((Bar))";
is walk(Pod::Walker, $=pod[1]).gist, "(((((Bar)))))";
is walk(Pod::Walker, $=pod[2]).gist, "((Bar))";
is walk(Pod::Walker, $=pod[3]).gist, "(((Bar)))";
is walk(Pod::Walker, $=pod[5]).gist, "((1 (The Problem)) (2 (The Solution)) (2.1 (Analysis)))";
#TODO: unit test :formatted
is walk(Pod::Walker, $=pod[6]).gist, q[(Pod::Config.new(type => "head1", config => {:formatted("B U"), :numbered("1")}) Pod::Config.new(type => "head2", config => {:formatted("I")}) ((1 (Bar))) ((Baz)))];
is walk(Pod::Walker, $=pod[7]).gist, q[(Pod::Config.new(type => "head1", config => {:formatted("B U"), :numbered("1")}) Pod::Config.new(type => "head2", config => {:like("head1")}) ((1 1 (Bar))) (1.1 (Baz)) ((1.1.1 (Buzz))))]

