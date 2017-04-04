# Upcoming

*The trivial event calendar*

This is a trivial event tracker. It can be used as follows:

```
$ upcoming.rb 4/11 "Jazz performance"
```

Then, on 4/11, the system will email you a reminder about the Jazz performance.

For maximum laziness the script supports a wide array of date formats, such as "March 5th", or "Tuesday".

## Installation

Put the script anywhere, and change the constants at the top to the appropriate email addresses and paths.

Next add a line to your crontab as follows:

```
0 0 * * *  /path/to/script/upcoming.rb -d
```

The script will now be run daily by cron in daemon mode, which emails current events out and removes them from the update queue.

This script has a dependency on the 'mail' gem.

## Why does this exist? Why not use one of the many other calendar systems available?

I wanted something extremely simple that does exactly what I ask of it and nothing more.
