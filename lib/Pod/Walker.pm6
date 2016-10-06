use Pod::Config;
class Pod::DefintionList is Pod::Block {};
class Pod::NumberedBlock is Pod::Block { };

role Pod::Walker {
    has @!stack;
    has %!config; # Stores %config directives
    has Callable $!pre = { $_ } ;
    has Callable $!post = { $_ };
    has @!number = (0,); #Stores :numbered state
    has @.bullets = ('-', '*', '>');

    multi method assemble(Nil, $body) { $body; }
    multi method assemble(Array $node, $body) {  $node.map({ $_.gist }).join(",") }
    # multi method assemble(Pod::Block::Declarator $node) { $node; }
    # multi method assemble(Pod::Block::Code $node) { $node; }
    # multi method assemble(Pod::Block::Comment $node) { $node; }
    # multi method assemble(Pod::Heading $node, $body) { $body; }
    # multi method assemble(Pod::List $node) { $node; }
    multi method assemble(Pod::Block::Table $node, $rows) { 
        my List @content = $node.headers ?? 
            zip_longest($node.headers, $rows, :fillvalue("")) 
            !! zip_longest((<""> xx $rows.elems), $rows);
        my Str $caption = $node.caption ?? "({$node.caption})" !! "";
        "\{" ~ @content.map(-> ($header, $row) { $header ~ " [{ $row.map({ "($_)" }) }] " }) ~ "}$caption";
    }
    multi method assemble(Pod::Block::Named $node, $body) { 
        given $node.name {
            when 'defn' { 
                my $word = $body.split(' ')[0]; 
                my $defn = $body.split(' ')[1..*-1]; 
                return "($word : $defn)";
            }
        }
        "($body)";
    }
    multi method assemble(Pod::Item $node, $body) { 
        return "((" ~ self.numbered($node, $node.level) ~ ")" ~ $body ~ ")" if $node.config{"numbered"}:exists;
        my $bullet = @.bullets[($node.level % @.bullets.elems)]; 
        "(($bullet)($body))"; 
    }
    multi method assemble($node, $body) { 
        return "((" ~ self.numbered($node, $node.level) ~ ")" ~ $body ~ ")" if $node.config{"numbered"}:exists;
        "($body)"; 
    }

    multi method visit(Pod::Block::Table $node) {
        my $n = self.nodeConfig($node);
        my Array @rows = $n.contents.map({ $_.map({ self.visit: $^__ }).Array }); #For type reasons;
        self.assemble($n, @rows);
    }
    multi method visit(Str $node) { 
        if $node ~~ /^\h?\#\h?/ {
            @!stack[*-2].config{'numbered'} = 1;
            return $node.substr($/.to); 
        }        
        $node; 
    }
    multi method visit(Pod::Config $node) {
        %!config{$node.type} = %!config{$node.config{"like"}} if $node.config{"like"}:exists;
        for $node.config.kv -> $k, $v { 
            %!config{$node.type} = Hash.new() unless %!config{$node.type};
            %!config{$node.type}{$k} = $v;
        }
    }
    multi method visit($node) { 
        self.applyConfig($node);
        my $n = self.nodeConfig($node);
        @!stack.push($n);
        my $parsed = $n.contents.map({ self.visit($_) }).join;
        $parsed = self.assemble($n, $parsed);
        @!stack.pop();
        $parsed;
    }

    #The config methods are stateful methods modifying $node in place. I don't intend to use the return values.
    method applyConfig($node) {
        return $node unless %!config{getPodType($node)}:exists;
        self.mergeConfigs($node, %!config{getPodType($node)});
    }
    method mergeConfigs($node, %other) {
        for %other.kv -> $k, $v {
            $node.config{$k} = $v unless $node.config{$k}:exists;
        }
    }
    multi method nodeConfig($node is copy) is export {
        return $node unless $node.^lookup("config");
        self.mergeConfigs($node, %!config{$node.config{"like"}}) if $node.config{"like"}:exists;
        for $node.config.kv -> $key, $value {
            given $key {
                when "nested" { 
                    $node = nested($node, Int($value)) unless $value == 0;
                }
                when "formatted" { 
                    $node.contents = [formatted($node, $value.split(" "))];
                }
            }
        }
        $node;
    }

    multi method numbered($node, Int $level) is export {
        #Logic for dealing with whether or not the count should be reset
        state $prevType = Nil;
        @!number = (0,) if not ($prevType ~~ $node.WHAT) and not ($node.config{'continued'}:exists);
        $prevType = $node.WHAT;
        #End reset logic
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
    $walker.visit: $root;
}

