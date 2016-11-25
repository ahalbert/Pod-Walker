use Pod::Config;
class Pod::NumberedBlock is Pod::Block { };
class Pod::Block::Named::Semantic is Pod::Block::Named { };

my @SemanticBlocks = qw<NAME AUTHOR CREATED EXCLUDES DESCRIPTION INTERFACE SUBROUTINE DIAGNOSTIC WARNING BUG ACKNOWLEDGEMENT DISCLAIMER LICENSE SECTION APPENDIX INDEX SUMMARY SYNOPSIS>;

role Pod::Walker {
    has @!stack;
    has %!config; # Stores %config directives
    has %!aliases; #Stores aliased code
    has Callable $!pre = { $_ } ;
    has Callable $!post = { $_ };
    has @!number = (0,); #Stores :numbered state
    has @.bullets = ('-', '*', '>');
    has %.index;

    multi method assemble(Nil, $body) { $body; }
    multi method assemble(Array $node, $body) { $node.map({ self.assemble($_, $body); }); }
    multi method assemble(Str $node, $body) { $node; }
    # multi method assemble(Pod::Block::Declarator $node) { $node; }
    multi method assemble(Pod::Block::Code $node, $body) { "C<$body>"; }
    multi method assemble(Pod::Block::Comment $node, $body) { ""; }
    multi method assemble(Pod::FormattingCode $node, $body) { self.assemble($node, $body, $node.type); }
    multi method assemble(Pod::FormattingCode $node, $body, $type) { "{$type}<$body>"; }
    multi method assemble(Pod::FormattingCode $node, $body, "L") { "(({$node.meta})<$body>)"}
    multi method assemble(Pod::FormattingCode $node, $body, "E") { $node.contents[0];}
    multi method assemble(Pod::FormattingCode $node, $body, "X") { self.addIndex($node); '';}
    multi method assemble(Pod::FormattingCode $node, $body, "P") { 
        my $filename =  $node.contents.substr(5); 
        "({$filename.IO.slurp.trim})";
    }
    multi method assemble(Pod::FormattingCode $node, $body, "A") { 
        return "({self.visit(%!aliases{$node.contents[0]})})" if  %!aliases{$node.contents[0]}:exists;
        "A($body)";
    }
    # multi method assemble(Pod::Heading $node, $body) { $body; }
    # multi method assemble(Pod::List $node) { $node; }
    multi method assemble(Pod::Block::Table $node, $rows) { 
        my List @content = $node.headers 
            ?? zip_longest($node.headers, $rows, :fillvalue("")) 
            !! zip_longest((<""> xx $rows.elems), $rows);
        my Str $caption = $node.config{'caption'}:exists ?? "({$node.config{'caption'}})" !! "";
        $caption = $node.caption ?? "({$node.caption})" !! $caption;
        "\{" ~ @content.map(-> ($header, $row) { $header ~ " [{ $row.map({ "($_)" }) }] " }) ~ "}$caption";
    }
    multi method assemble(Pod::Block::Named $node, $body, $name) { "($body)"; }
    multi method assemble(Pod::Block::Named::Semantic $node, $body, $name) { "(({$node.name}) ($body))"; }
    multi method assemble(Pod::Block::Named $node, $body, "data") { ""; }
    multi method assemble(Pod::Block::Named $node, $body, "alias") { self.addAlias($node); "";}
    multi method assemble(Pod::Block::Named $node, $body, "defn") { 
        my $word = $body.split(' ')[0]; 
        my $defn = $body.split(' ')[1..*-1]; 
        "($word : $defn)";
    }
    multi method assemble(Pod::Block::Named $node, $body) { 
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

    multi method visit(Pod::Block::Named $node) {
        self.applyConfig($node);
        my $n = self.nodeConfig($node);
        if $node.name ∈ @SemanticBlocks {
            $n = Pod::Block::Named::Semantic.new(name => $n.name, config => $n.config, contents => $n.contents);
        }
        @!stack.push: $n;
        my $parsed = $n.contents.map({ self.visit($_) }).join;
        $parsed = self.assemble($n, $parsed, $n.name);
        @!stack.pop;
        $parsed;
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
    multi method visit(Array $node) {
        my @parsed;
        @parsed.push(self.visit($_)) for $node.List;
        return @parsed.join;
    }
    multi method visit($node) { 
        self.applyConfig($node);
        my $n = self.nodeConfig($node);
        @!stack.push: $n;
        my $parsed = $n.contents.map({ self.visit($_) }).join;
        $parsed = self.assemble($n, $parsed);
        @!stack.pop;
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
    multi method nodeConfig($node is copy) {
        return $node unless $node.^lookup("config");
        self.mergeConfigs($node, %!config{$node.config{"like"}}) if $node.config{"like"}:exists;
        for $node.config.kv -> $key, $value {
            given $key {
                when "nested" { 
                    $node.contents = nested($node, Int($value)) unless $value <= 0;
                }
                when "formatted" { 
                    $node.contents = [formatted($node, $value.split(" "))];
                }
            }
        }
        $node;
    }
    multi method addAlias($node) {
        self.visit($node.contents[0]) ~~ /'('(\S+\s+)(.*)')'/; #Match aginst first word as alias name, then take rest as content.
        %!aliases{$0.trim} = "$1";
    }
    multi sub splitAliasedPara(Pod::Block::Para $para) { $para.contents.trim.split(' '); }
    multi sub splitAliasedPara(Str $para) { $para.trim.split(' '); }

    multi method addIndex($node) {
        if ($node.meta.elems > 1) {
            %!index{$node.contents[0]} = $node.meta.elems 
        } else {
            %!index{$node.contents[0]} = $node.contents;
        }
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

