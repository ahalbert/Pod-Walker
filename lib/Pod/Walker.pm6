class Pod::List is Pod::Block { };

role Pod::Walker {
    has @!stack;
    has Callable $!pre;
    has Callable $!post;

    multi method do(Nil) { }
    multi method do(Pod::Block::Named $node) { $node; }
    multi method do(Pod::Block::Declarator $node) { $node; }
    multi method do(Pod::Block::Code $node) { $node; }
    multi method do(Pod::Block::Comment $node) { $node; }
    multi method do(Pod::Block::Table $node) { $node; }
    multi method do(Pod::Config $node) {  $node; }
    multi method do(Pod::Heading $node) { $node;}
    multi method do(Pod::List $node) { $node; }
    multi method do(Pod::Item $node) { $node; }
    multi method do(Positional $node) { $node.map: { self.do($_) } }
    multi method do(Str $node) {  $node; }
    multi method do($node) {  $node;}

    multi method visit(Nil) {} 
    multi method visit($node) { 
        #$node = $!pre($node) if defined $!pre;
        @!stack.push($node);
        self.do($node);
        $node.?contents.map: { self.visit: $_};
        @!stack.pop();
        #$!post($node) if defined $!post;
    }
}

multi sub walk(Pod::Walker:U $walker, $root) is export { #TODO: %*args;
    $walker.new().visit: $root;
}

multi sub walk(Pod::Walker:D $walker, $root) is export {
    $root.contents ==> map { $walker.visit: $_ };
}
