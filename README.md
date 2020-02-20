# kv.awk
A dumb key/value store implemented in awk & plain-text files

To install, make sure `kv.awk` is executable

    chmod +x kv.awk

and drop `kv.awk` in your `$PATH`.

Or don't.  You can invoke it by full path too.

Usage:

    $ kv.awk <storename> <command> [args]

For the examples below, I use a `storename` of "example"
which will get stored in `example.txt`

To add a key use `add` (or `set`):

    $ kv.awk example add mykey "this is my value"

To list all the keys & values use `list` (or `ls`):

    $ kv.awk example list

To get the value of a particular key "mykey"

    $ kv.awk example get mykey

To get the value of multiple keys:

    $ kv.awk example get mykey1 mykey2

To delete a key use `delete` (or `del` or `rm`):

    $ kv.awk example delete mykey

To delete the value of multiple keys:

    $ kv.awk example delete mykey1 mykey2

`kv.awk` stores data in `$HOME/.config/kv.awk/<storename>.txt`
as a tab-delimited file unless `$HOME` is unset
in which case it uses the current directory.

Newlines in the key or value will break things
but in predictable ways.

Empty lines
and lines beginning with a "#" are ignored
but will get overwritten/removed the next time the data-store is changed.

Data is not guaranteed to stay in the same order.

Inspired by [@JuanIbiapina's `shelf`](https://github.com/juanibiapina/shelf)
which was written in Rust.
So I decided to give it a try in `awk`
to see how it would go.
I did change the parameter order from
"[command] [storename]"
to
"[storename] [command]"
because I found that easier to work with.
