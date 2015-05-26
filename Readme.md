Space Cadet
===========

Space Cadet is a test library for [Haxe](http://haxe.org/),
aimed to be like Ruby's [RSpec](http://rspec.info/).

It works, but has no runner,
which is why it's not published,
and won't be maintained.


Example output
--------------

Using Space Cadet to test itself (runner was written in Ruby):

![images/running.png]


Some skips and final results:

![images/results.png]

History
-------

Extracted this out of a haxe project.
Right now it has no actual runner,
I spent several hours trying to figure
out how to get a [macro](https://gist.github.com/JoshCheek/2fdaba7abdd22aac8c61)
to build the haxe function.
But ultimately it wore me down for like the hundredth time,
and I gave up and just wrote the tool I was wanting to use this for, in Rust.

Still, went to the effort to extract it out,
so I'll leave this here, either for reference,
or in case I come back to the language.


License
-------

[Just do what the fuck you want to.](http://www.wtfpl.net/about/)
