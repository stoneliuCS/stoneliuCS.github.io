---
layout: posts
author: Stone Liu
---

Back in the _"yee old days"_ physical terminals looked like [type-writers](https://en.wikipedia.org/wiki/Typewriter).
They were fed physical tapes that could be used to "punch" program outputs. 
The tape could even be read back into the machine for further program processing. _(pretty neat stuff eh?)_.

Nowadays we have [IDEs](https://en.wikipedia.org/wiki/Integrated_development_environment), entire systems driven for software development. They provide everything from programming language autocomplete, refactoring, debugging analysis and even agentic coding. So then again why ever go back to the way things were?

Everytime you open the terminal you see a black abyss peering into your soul. _(Indeed, that is your reflection.)_. Its
a world where you feel like you need to memorize magical incantations and spells so that you can just do the same thing
you can with the click of a mouse.

### To a Hammer Everything Looks like a Nail
Once we get familiar with a tool we sometimes want to use it for everything. I am by no means an exception to this, I
love [(neo)vim](https://github.com/neovim) and write everything in it. Maybe not to the same level as [emacs](https://www.vim.org/) users _(do they ever leave it?)_.
<div style="text-align:center;">
    <img src="/assets/images/do_you_mean_emacs.png" alt="Do you mean Emacs" class="medium-image">
</div>
One thing I will say is that command line applications are more powerful than gui applications if you know how to use
them. Alot of the bespoke tools from the bygone eras have been modernized and revamped. _(Seriously! take a look at fzf,
ripgrep, and bat)_. 

But one of the best things about using a command line interface over a gui, especially on [UNIX](https://en.wikipedia.org/wiki/Unix) systems is that you can connect any and every cli program together. This is because in _UNIX_, everything is a file. So after you are done using [fzf](https://github.com/junegunn/fzf) to look for that specific file on your system, you can pipe the output of that program into a text-editor like _vim_ and start slamming down keys like a badass.

In the age of _GUIs_ it might feel a little archaic to use a terminal interface.
Afterall, why do I need to learn a bunch of magical incantations when a button can do the same thing for me? For simple
use cases, its much better to use a _GUI_ to accomplish tasks. _GUIs_ promote **discoverability**, its just much easier 
to find things in a _GUI_ as opposed to a command line interface. However, the power of the command line lies in its
ability to chain, pipe, and compose simpler commands to accomplish more complex tasks. For example, say I wanted to find
all file logs in a repository, search each log and remove the word "stone" from each file, store the removed word in a
output file with the location of where I removed the word from each log file. _Totally random right?_ But I gurantee you
that no GUI application has a button for that. If it did, it would be hopelessly complicated as opposed to writing a
simple shell script:
<div style="text-align:center;">
    <img src="{{ '/assets/images/script.svg'}}" alt="Sudo" class="medium-image">
    <img src="{{ '/assets/images/fcking_rm.svg'}}" alt="Sudo" class="small-image">
</div>
