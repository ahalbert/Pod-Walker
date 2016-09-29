use Pod::Config;
class Pod::List is Pod::Block { };

role Pod::Walker {
    has @!stack;
    has %!config; # Stores %config directives
    has Callable $!pre = { $_ } ;
    has Callable $!post = { $_ };
    has @!number = (0,); #Stores :numbered state
    has @.bullets = ('-', '*', '>');

    multi method assemble(Nil, $body) { Nil; }
    # multi method assemble(Pod::Block::Named $node) { say $node.config; $node; }
    # multi method assemble(Pod::Block::Declarator $node) { $node; }
    # multi method assemble(Pod::Block::Code $node) { $node; }
    # multi method assemble(Pod::Block::Comment $node) { $node; }
    # multi method assemble(Pod::Block::Table $node) { $node; }
    # multi method assemble(Pod::Heading $node) { $node;}
    # multi method assemble(Pod::List $node) { $node; }
    multi method assemble(Pod::Item $node, $body is copy) { 
        my $bullet = @.bullets[($node.level % @.bullets.elems)]; 
        "($bullet$body)"; 
    }
    multi method assemble($node, $body) { "($body)"; }

    multi method visit(Nil) { } 
    multi method visit(Str $node) { $node; }
    multi method visit(Array $node) { $node.map: {self.visit: $_} }
    multi method visit(Pod::Config $node) {
        %!config{$node.type} = %!config{$node.config{"like"}} if $node.config{"like"}:exists;
        for $node.config.kv -> $k, $v { 
            %!config{$node.type} = Hash.new() unless %!config{$node.type};
            %!config{$node.type}{$k} = $v;
        }
        $node;
    }

    multi method visit($node) { 
        self.applyConfig($node);
        my $n = self.nodeConfig($node);
        @!stack.push($n);
        my $parsed = $node.contents.map({ self.visit($_) }).join;
        $parsed = self.assemble($n, $parsed);
        @!stack.pop();
        $parsed;
    }

    #The config methods are stateful methods modifying $node in place. I don't intend to use the return values.
    method applyConfig($node) {
        return $node.config unless %!config{getPodType($node)}:exists;
        self.mergeConfigs($node, %!config{getPodType($node)});
    }
    method mergeConfigs($node, %other) {
        for %other.kv -> $k, $v {
            $node.config{$k} = $v unless $node.config{$k}:exists;
        }
        $node.config;
    }
    multi method nodeConfig($node is copy) is export {
        return $node unless $node.^lookup("config");
        self.mergeConfigs($node, %!config{$node.config{"like"}}) if $node.config{"like"}:exists;
        for $node.config.kv -> $key, $value {
            given $key {
                when "nested" { $node = nested($node, Int($value)) }
                when "formatted" { $node = formatted($node, $value.split(" ")) }
                when "numbered" { @!stack[*-1].contents.unshift(self.numbered($node.level)) }
            }
        }
        $node;
    }

    method numbered(Int $level) is export {
        if @!number.elems > $level {
            @!number.pop() while @!number.elems > $level;
        }
        else {  
            @!number.push(0) while @!number.elems < $level;
        }
        @!number[*-1]++;
        @!number.join('.');
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

