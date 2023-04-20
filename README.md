# dotfiles

My cross platform dotfiles managed by [chezmoi](https://www.chezmoi.io/).

## User Program Data

I use `~/.config/` to store my configuration preferences (for user program data, such as bash, zsh, iterm2, Visual Studio Code, etc.).

> This is a recent innovation, followed by Gnome and thus by Ubuntu, to store user-specific data in fixed directories. 
>
> According to this [document](http://standards.freedesktop.org/basedir-spec/basedir-spec-latest.html), there is:
> 
>    * a single directory where user data is stored (program state from my use), defaulting to `~/.local/share`;
>    * a single directory where configuration (my preferences) is stored, defaulting to `~/.config`;
>    * a single directory which holds non-essential data files (deletable cache), defaulting to `~/.cache`.
>
> Historically, Unix programs were free to spread their data all over the `$HOME` directory, putting their data in dot-files (files starting with ".") or subdirectories such as ~/.vimrc and ~/.vim. 
> The new specification is intended to make this behavior more predictable. I suspect this makes backups of application data easier, in addition to giving your home directory a tidier appearance. 
> 
> **Not all applications adhere to this standard <ins>yet</ins>!**
>
> Source: https://askubuntu.com/a/14536
