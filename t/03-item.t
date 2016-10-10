use Test;
use Pod::Walker;
plan 5;
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
#2
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
#3
=begin ContinuedListTest
=for item1 :numbered
Retreat to remote Himalayan monastery

=for item1 :numbered
Learn the hidden mysteries of space and time

I<????>

=for item1 :numbered :continued
Prophet!
=end ContinuedListTest
#4
=begin DefintionListTest
    =defn  MAD
    Affected with a high degree of intellectual independence.

    =defn  MEEKNESS
    Uncommon patience in planning a revenge that is worth while.

    =defn
    MORAL
    Conforming to a local and mutable standard of right.
    Having the quality of general expediency.
=end DefintionListTest

is walk(Pod::Walker, $=pod[0]), "(((*)((Happy)))((*)((Dopey)))((*)((Sleepy)))((*)((Bashful)))((*)((Sneezy)))((*)((Grumpy)))((*)((Keyser Soze))))";
is walk(Pod::Walker, $=pod[1]), "(((*)((Animal)))((>)((Vertebrate)))((>)((Invertebrate)))((*)((Phase)))((>)((Solid)))((>)((Liquid)))((>)((Gas)))((>)((Chocolate))))";
is walk(Pod::Walker, $=pod[2]), "(((1)(Visito))((1.1)(Veni))((1.2)(Vidi))((1.3)(Vici)))";
is walk(Pod::Walker, $=pod[3]), "(((1)(Retreat to remote Himalayan monastery))((2)(Learn the hidden mysteries of space and time))(I<????>)((3)(Prophet!)))";
is walk(Pod::Walker, $=pod[4]), "(((MAD : Affected with a high degree of intellectual independence.))((MEEKNESS : Uncommon patience in planning a revenge that is worth while.))((MORAL : Conforming to a local and mutable standard of right. Having the quality of general expediency.)))";
