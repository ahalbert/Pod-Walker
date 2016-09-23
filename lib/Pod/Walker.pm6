class Pod::List is Pod::Block { };
class Pod::Nested is Pod::Block { };

role Pod::Walker {
    has @!stack;
    has Callable $!pre;
    has Callable $!post;

    multi method do(Nil) { }
    # multi method do(Pod::Block::Named $node) { say $node.config; $node; }
    # multi method do(Pod::Block::Declarator $node) { $node; }
    # multi method do(Pod::Block::Code $node) { $node; }
    # multi method do(Pod::Block::Comment $node) { $node; }
    # multi method do(Pod::Block::Table $node) { $node; }
    # multi method do(Pod::Config $node) {  $node; }
    # multi method do(Pod::Heading $node) { $node;}
    # multi method do(Pod::List $node) { $node; }
    # multi method do(Pod::Item $node) { $node; }
    multi method do(Positional $node) { $node.map: { self.visit($_) } }
    multi method do(Str $node) { $node; }
    multi method do($node) {$node;}

    multi method visit(Nil) { Nil;} 
    multi method visit(Str $node) { $node; }
    multi method visit(Array $node) { $node.map: {self.visit: $_} }
    multi method visit($node) { 
        #$node = $!pre($node) if defined $!pre;
        @!stack.push($node);
        my $n = nodeConfig($node);
        my $body = $n.contents.map: { self.visit: $_};
        @!stack.pop();
        $body;
        #$!post($node) if defined $!post;
    }
}

multi sub walk(Pod::Walker:U $walker, $root) is export { #TODO: %*args;
    walk $walker.new(), $root;
}

multi sub walk(Pod::Walker:D $walker, Pod::Block $root) is export {
    $root.contents ==> map { $walker.visit: $_ };
}

multi sub walk(Pod::Walker:D $walker, Array $root) is export {
    $root ==> map {$walker.visit: $_};
}


multi sub nodeConfig($node) { $node; }
multi sub nodeConfig(Pod::Block $node is rw) {
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

multi sub formatted($node, []) { $node; }
multi sub formatted($node, @codes) {
    formatted(Pod::FormattingCode.new(contents => $node.contents, type => (@codes.head)), @codes[1..*-1]);
}
