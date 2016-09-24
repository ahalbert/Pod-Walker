use Pod::Config;
class Pod::List is Pod::Block { };

role Pod::Walker {
    has @!stack;
    has Callable $!pre = { $_ } ;
    has Callable $!post = { $_ };

    multi method assemble(Nil) { }
    # multi method assemble(Pod::Block::Named $node) { say $node.config; $node; }
    # multi method assemble(Pod::Block::Declarator $node) { $node; }
    # multi method assemble(Pod::Block::Code $node) { $node; }
    # multi method assemble(Pod::Block::Comment $node) { $node; }
    # multi method assemble(Pod::Block::Table $node) { $node; }
    # multi method assemble(Pod::Config $node) {  $node; }
    # multi method assemble(Pod::Heading $node) { $node;}
    # multi method assemble(Pod::List $node) { $node; }
    # multi method assemble(Pod::Item $node) { $node; }
    multi method assemble(Positional $node) { $node; }
    multi method assemble(Str $node) { $node; }
    multi method assemble($node) {$node.WHAT;}

    multi method visit(Nil) { } 
    multi method visit(Str $node) { $node; }
    multi method visit(Array $node) { $node.map: {self.visit: $_} }
    multi method visit($node) { 
        @!stack.push($node);
        my $n = nodeConfig($node);
        my $body = $n.contents.map: { self.visit: $_};
        my $parsed = self.assemble($body);
        @!stack.pop();
        $parsed;
    }
}

multi sub walk(Pod::Walker:U $walker, $root) is export { #TOassemble: %*args;
    walk $walker.new(), $root;
}

multi sub walk(Pod::Walker:D $walker, Array $root) is export {
    $root ==> map {$walker.visit: $_};
}

multi sub walk(Pod::Walker:D $walker, Pod::Block $root) is export {
    $walker.visit: $root ;
}

