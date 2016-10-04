use Test;
use Pod::Walker;
plan 1;
#0
=begin TableTest
=table
    The Shoveller   Eddie Stevens     King Arthur's singing shovel
    Blue Raja       Geoffrey Smith    Master of cutlery
    Mr Furious      Roy Orson         Ticking time bomb of fury
    The Bowler      Carol Pinnsler    Haunted bowling ball
=end TableTest
#1
=begin HeaderTableTest
=table
    =table
        Superhero     | Secret          |
                      | Identity        | Superpower
        ==============|=================|================================
        The Shoveller | Eddie Stevens   | King Arthur's singing shovel
        Blue Raja     | Geoffrey Smith  | Master of cutlery
        Mr Furious    | Roy Orson       | Ticking time bomb of fury
        The Bowler    | Carol Pinnsler  | Haunted bowling ball
=end HeaderTableTest

=begin CaptionedTableTest
    =begin table :caption('The Other Guys')

                        Secret
        Superhero       Identity          Superpower
        =============   ===============   ===================
        The Shoveller   Eddie Stevens     King Arthur's
                                          singing shovel

        Blue Raja       Geoffrey Smith    Master of cutlery

        Mr Furious      Roy Orson         Ticking time bomb
                                          of fury

        The Bowler      Carol Pinnsler    Haunted bowling ball

    =end table
=end CaptionedTableTest
is walk(Pod::Walker, $=pod[0]), Q"({[(The Shoveller,Eddie Stevens,King Arthur's singing shovel)][(Blue Raja,Geoffrey Smith,Master of cutlery)][(Mr Furious,Roy Orson,Ticking time bomb of fury)][(The Bowler,Carol Pinnsler,Haunted bowling ball)]})";
