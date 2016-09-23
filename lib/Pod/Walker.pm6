class Pod::List is Pod::Block { };
class Pod::Nested is Pod::Block { };

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

multi sub walk(Pod::Walker:D $walker, Pod::Block $root) is export {
    $root.contents ==> map { $walker.visit: $_ };
}

multi sub walk(Pod::Walker:D $walker, Array $root) is export {
    $root ==> map {$walker.visit: $_};
}


multi sub nodeConfig($node is copy) {
    return $node unless $node.^lookup("config");
    for $node.config.kv -> $key, $value {
        given $key {
            when "nested" { $node = nested($node, Int($value)) }
            when "formatted" { $node = formatted($node, $value.split(" ")) }
        }
    }
    $node;
}

multi sub nested($node, 0) {$node.contents;}
multi sub nested($node, Int $level) {
    Pod::Nested.new(contents => [nested($node, $level - 1)]);
}

multi sub formatted($node, @codes) {
    return $node.contents unless @codes; #I wanted to implement multi sub for () but it's broken.
    say @codes;
    Pod::FormattingCode.new(contents => flat(formatted($node, @codes[1..*-1]),), type => @codes[0]);
}
