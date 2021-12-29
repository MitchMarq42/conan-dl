<!-- # This is working now. Sort of. Somehow. Filenames are broken, but it does read the config file, and it does download episodes to the proper directory. -->
## This is broken at present. [cdl-stable](old/cdl-stable) is the version I would recommend, but gogoanime changed their protocol again. Removed a line from the html. Now we suffer.

## I'm working on an aggressive refactor with multiple outs, but also have a real job so don't expect anything. No life though, thankfully. But hey, one of my patches was added to ani-cli, so it's almost as if Senpai noticed me (!)

Hey. This is a simple(ish) script/program to download anime from gogoanime.vc and save them to a directory on your device.
The current build
(as of 12/28/2021, 28/12/2021 for you Europeans)
does
NOT
work,
<!-- and uses -->
but would use
a combination of curl, youtube-dl, and various arcane shell-isms
and requires some semi-specific options in the config file. But whatever.
I made this mostly for myself, and if you want to use it for yourself
you can debug and fix it for yourself too. Good luck.

---

## Installation:

0. Dependencies:

  - A POSIX-compliant shell. Basically anything other than `fish` or `powershell` will work, and this can still be called even from those.

  - `curl` (if you don't know, you probably have it)

  - `sed` (if you don't know, you probably have it)

  - `youtube-dl` (yt-dlp is preferred as it's better)

  - `fzf` or another simple menu like `dmenu`. Must be specified with the `$menu` variable.

1. I recommend downloading and placing the files manually. And I won't provide another way unless someone asks.

  conan-dl.conf goes in the directory `~/.config/conan-dl` which you probably don't have. Go ahead and make it.

  The executable (currently conan-dl, but could change) goes somewhere in your `$PATH`.

  domains.info and the other files are currently unused, but they might be used in future releases. You don't have to have them.

2. Modify the config file conan-dl.conf

  tmpdir should be /tmp

  Anything else, you're on your own

## FAQ:

I've never been asked about this, but here are some hypothetically important questions one might ask.

1. Is this legal?

  Not really, but neither is the service it's relying on. So running this script has the same legality as just streaming the content directly from their website-- THEY hold the blame, you are just a lurking beneficiary of their illicit service.

  That said, DO NOT sell anything you get using this. Probably don't brag about it either. If you use my software and make extremely dumb mistakes like getting caught in a prosecutable act, I will deny any involvement and laugh at you. And in return if I make that mistake you can laugh at me.

2. It doesn't work!!

  Of course not. I'm basically trying to match pace with gogoanime, who are themselves sprinting at arm's length to get away from the FBI and countless Japanese legal teams. Changing URLs and server hosts is basically unavoidable for them. And if I made a tool that could actually keep track of that, so could anyone. And that might mean the end.

  Oh, you want to fix it? Run the script with ```bash -x `which conan-dl` ``` and see what step it gets stuck on. Probably some variable never got defined, or some other stupid error happened. One thing you can do is open the last successful URL in your browser, and add "view-source:" to the beginning of the URL. This will print out the raw HTML, which you can then scroll through or use your browser's ctrl-F to locate the offending string. Try changing the mirrorfz values in the config file or something.

3. You are evil and I hate this in every way. Take it down!

  That's not a question. And I'm sorry you hate me, but you could also just mind your own business. And I'm not just taking this down because someone hates it. I'll take it down if I get in trouble for it, and even if that never happens it'll probably be deprecated pretty quickly anyways (see answer to #2).

4. I want to help

  Cool. You can submit a pull request, or open an issue, or send me a letter via post. If you find my mailbox. Please don't.

  If you do have a genuine improvement to bring, however, do feel free to open the proper channel and submit it.

## Special Thanks:

- (pystardust)[https://github.com/pystardust] for making this concept popular

- (Dink4n)[https://github.com/Dink4n] for fixing his work and thus mine

- Texas Instruments for embedding an interesting language into their ~~80s iPhones~~calculators

- My friends Charles and Macklen for getting me into anime and coding, respectively

- Sir Tim Burners Lee for the Internet

EOF
