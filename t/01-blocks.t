
use Pod::Walker;

=begin foo 
    Foo
=end foo


=for head1
Foor

=table
  col1  col2

#=[ This text stored in C<&fu.WHY>, not in C<$bar.WHY>,
#=        (because C<sub fu> is the declarator
#=                 at the I<start> of the preceding line)
            ]

is walk(Pod::Walker, $=pod).gist eq [Pod::Block::Named.new(name => "foo", config => {}, 
                                            contents => [Pod::Block::Para.new(config => {}, contents => ["Foo"])]), 
                                        Pod::Heading.new(level => 1, config => {}, contents => 
                                            [Pod::Block::Para.new(config => {}, 
                                                contents => ["Foor"])]), 
                                        Pod::Block::Table.new(caption => Any, headers => [], config => {}, 
                                            contents => [["col1", "col2"],])].gist;

