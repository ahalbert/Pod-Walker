use Test;
use Pod::Walker;
plan 2;
#0
=begin ListTest
=item  Happy
=item  Dopey
=item  Sleepy
=item  Bashful
=item  Sneezy
=item  Grumpy
=item  Keyser Soze
=end ListTest
#1
=begin LeveledListTest
=item1  Animal
=item2     Vertebrate
=item2     Invertebrate

=item1  Phase
=item2     Solid
=item2     Liquid
=item2     Gas
=item2     Chocolate
=end LeveledListTest

=begin NumberedListTest
=for item1 :numbered
Visito

=for item2 :numbered
Veni

=for item2 :numbered
Vidi

=for item2 :numbered
Vici
=end NumberedListTest

is walk(Pod::Walker, $=pod[0]), "(((*)((Happy)))((*)((Dopey)))((*)((Sleepy)))((*)((Bashful)))((*)((Sneezy)))((*)((Grumpy)))((*)((Keyser Soze))))";
is walk(Pod::Walker, $=pod[1]), "(((*)((Animal)))((>)((Vertebrate)))((>)((Invertebrate)))((*)((Phase)))((>)((Solid)))((>)((Liquid)))((>)((Gas)))((>)((Chocolate))))";
is walk(Pod::Walker, $=pod[2]), "(((1)(Visito))((1.1)(Veni))((1.2)(Vidi))((1.3)(Vici)))";
