class Pod::Nested is Pod::Block { };

multi sub nodeConfig($node is copy) is export {
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
    Pod::FormattingCode.new(contents => flat(formatted($node, @codes[1..*-1]),), type => @codes[0]);
}
