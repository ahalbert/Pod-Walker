use Pod::Walker;

my $css = q:to/END/;;
<style>
    /* code gets the browser-default font
    * kbd gets a slightly less common monospace font
    * samp gets the hard pixelly fonts
    */
    kbd { font-family: "Droid Sans Mono", "Luxi Mono", "Inconsolata", monospace }
    samp { font-family: "Terminus", "Courier", "Lucida Console", monospace }
    /* WHATWG HTML frowns on the use of <u> because it looks like a link,
    * so we make it not look like one.
    */
    u \{ text-decoration: none }
    .nested {
        margin-left: 3em;
    }
    // footnote things:
    aside, u { opacity: 0.7 }
    a[id^="fn-"]:target { background: #ff0 }
</style>
END

class Pod::To::HTML does Pod::Walker {
    has @!metadata;
    has %!config;

    multi method pod2html(($pod, 
        :&url = -> $url { $url }, 
        :$head = '', 
        :$header = '', 
        :$footer = '', 
        :$default-title, 
        :$css-url = '//design.perl6.org/perl.css', 
        :$lang = 'en',) {
            @body = visit $pod;

            qq:to/END/; 
            <!doctype html>
            <html lang="$lang">
            <head>
                <title>$title_html</title>
                <meta charset="UTF-8" />
                <link rel="stylesheet" href="$css-url">
                { metadata() }
                $head
            </head>
            <body class="pod" id="___top">
                {"<h1 class='title'>$title_html</h1>" if $title.defined}
                {"<p class='subtitle'>$subtitle</p>" if $subtitle.defined}
                { my $ToC := toc($pod) // () }
                <div class="pod-body', {$ToC ?? '' !! ' no-toc'}'">
                { self.visit(@body).join }
                </div>
                { footnotes() }
                $footer
            </body>
            </html>
            END
    }

    multi method pre($node) {
    }

    multi method do(Pod::Block::Heading $node) {  
        my $lvl = min($node.level, 6);
        qq:to/END/;
        <h$lvl>
            { inline($node.contents;}
        </h$lvl>
        END
    }
    multi method do(Pod::Block::Named $node) {  }
    multi method do(Pod::Block::Para $node) { "<p>" ~ visit($node.contents) ~ "</p>"}
    multi method do(Str $node) { escape_html($node); }
    
    method metadata() returns Str {
        @!metadata.map({
            qq[<meta name="{escape_html($_.key)}" value="{node2text($_.value)}" />]
        }).join("\n");
    }

    method footnotes() returns Str { "" }
    method toc($pod) returns Str { "" }


    multi method blockConfig($block) {$block}
    multi method blockConfig(Pod::Block $block) {}
}

sub escape_html(Str $str) returns Str {
    return $str unless $str ~~ /<[&<>"']>/;
    $str.trans( [ q{&},     q{<},    q{>},    q{"},      q{'}     ] =>
                [ q{&amp;}, q{&lt;}, q{&gt;}, q{&quot;}, q{&#39;} ] );
}

sub unescape_html(Str $str) returns Str {
    $str.trans( [ rx{'&amp;'}, rx{'&lt;'}, rx{'&gt;'}, rx{'&quot;'}, rx{'&#39;'} ] =>
                [ q{&},        q{<},       q{>},       q{"},         q{'}        ] );
}

sub makeid($id) returns Str {
    $node.trim.subst(/\s+/, '_', :g).subst('"', '&quot;', :g);
}

multi sub inline(Nil) returns Str { '' }
multi sub inline($node) returns Str {  inline($node.contents) }
multi sub inline(Str $node) returns Str { escape_html($node) }
multi sub inline(Positional $node) returns Str { 
    $node.map({ inline($_) }).join; 
}

multi sub node2rawtext(Nil) returns Str { '' }
multi sub node2rawtext($node) returns Str { $node.Str }
multi sub node2rawtext(Pod::Block $node) returns Str { node2rawtext($node.contents) }
multi sub node2rawtext(Str $node) returns Str { $node }
multi sub node2rawtext(Positional $node) returns Str {
    $node.map({ node2rawtext($_) }).join;
}

