class Pod::Nested is Pod::Block { };
#General utility functions for managing config options

multi sub getPodType($node) is export {
   given $node.WHAT {
       when Pod::Heading { return "head" ~ $node.level.Str;}
   }
   '';
}


multi sub nested($node, 0) is export { $node.contents; }
multi sub nested($node, Int $level) is export {
    Pod::Nested.new(contents => [nested($node, $level - 1)]);
}

multi sub formatted($node, @codes) is export {
    return $node.contents unless @codes; #I wanted to implement multi sub for () but it's broken.
    Pod::FormattingCode.new(contents => flat(formatted($node, @codes[1..*-1]),), type => @codes[0]);
}
