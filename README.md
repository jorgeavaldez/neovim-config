# jorge's neovim configs
this is my attempt at coming back from helix and spacemacs 

most of the bindings in helix are just so damn good. but vim is more widely supported and i'd rather get back the muscle
memory.

there's a lot that's missing of course since i'm a noob. this is also my first time dealing with lua configs.

## mantra
i prefer simplicity and speed over anything else. yeah maybe some of the choices here are debatable but this is my
config and i can do what i want.

i'm also learning, and i'm not sure i have a good understanding of everything yet. but we're experimenting so whatever.

## project files and ripgrep
i made it so ripgrep will show hidden files but also respect gitignore and hide .git directories.

if you want to also undo stuff gitignore is ignoring, like .env files, make sure to add a .ignore directory with
something like this:

```
!.env
!.env.*
!.env.*.local
```

## todo
- [ ] i set up all the textobject stuff and immediately realized i could have that stuff live in telescope. this todo is
  move everything to telescope

