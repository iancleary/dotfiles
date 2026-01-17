# -------------------------------------------------------------------------------------------------------------------------------
# .zprofile
# is sourced only for login shells — the first shell that starts when you log in or open a new terminal window.
# -------------------------------------------------------------------------------------------------------------------------------
# Key characteristics:
# ┌─────────────────┬─────────────────────────────────┐
# │ Aspect          │ .zprofile                       │
# ├─────────────────┼─────────────────────────────────┤
# │ When            │ Login shells only (not subshells)│
# │ Purpose         │ One-time setup at login         │
# │ Bash equivalent │ .bash_profile or .profile       │
# └─────────────────┴─────────────────────────────────┘
#
# Typical uses:
#
# * Setting environment variables that don't change (e.g., $EDITOR, $LANG)
# * Starting background services/agents (like ssh-agent)
# * Running commands that should only execute once per session
# * $PATH modifications (though many put these in .zshenv)
#
# Why use .zprofile instead of .zshenv?
#
# If a command:
# * Should run for every shell → .zshenv
# * Should run only once at login → .zprofile
#
# For example, starting ssh-agent in .zprofile prevents spawning multiple agents when you open subshells or run scripts.
# -------------------------------------------------------------------------------------------------------------------------------


# Setting PATH for Python 3.14
# The original version is saved in .zprofile.pysave
PATH="/Library/Frameworks/Python.framework/Versions/3.14/bin:${PATH}"
export PATH

##
# Your previous /Users/iancleary/.zprofile file was backed up as /Users/iancleary/.zprofile.macports-saved_2025-12-24_at_13:50:03
##

# MacPorts Installer addition on 2025-12-24_at_13:50:03: adding an appropriate PATH variable for use with MacPorts.
export PATH="/opt/local/bin:/opt/local/sbin:$PATH"
# Finished adapting your PATH environment variable for use with MacPorts.

