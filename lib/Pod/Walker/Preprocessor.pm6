
role Pod::Walker::Preprocessor {
    has %!aliases;
    multi method visit(Str $node) { }
    multi method visit(Pod::FormattingCode $node) {
        my $aliasName = $node.contents.first;
        $node.contents = %!aliases{$aliasName} if $node.type eq 'A' and %!aliases{$aliasName}:exists;
    }
    multi method visit(Pod::Block::Named $node) {
        return self.addAlias($node) if $node.name eq 'alias';
        $node.contents.map({ self.visit($_) });
    }
    multi method visit($node) {
        self.visit($_) for $node.contents;
    }
    submethod addAlias($node) {
        my @contents;
        #So it's not easy to tell if a Para has objects inside it as the Str can be many words
        if $node.contents[0].contents.elems > 1 {
            @contents = splitAliasedPara($node.contents[0].contents[0]);
            %!aliases{@contents[0]} = (|@contents[1..*-1], |$node.contents[0].contents[1..*-1] ==> grep { $_ ne ''}).Array;
        } else {
            @contents = splitAliasedPara($node.contents[0]);
            %!aliases{@contents[0]} = (@contents[1..*-1] ==> grep {$_ ne ''}).Array;
        }
    }
    multi sub splitAliasedPara(Pod::Block::Para $para) { $para.contents.trim.split(' '); }
    multi sub splitAliasedPara(Str $para) { $para.trim.split(' '); }
}

