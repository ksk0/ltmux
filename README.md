# What is ltmux?

The role of **ltmux** is to:
 - start **tmux** automatically on login session (the  one  which involves
   logging in  with credentials)
 - to attach to existing tmux session if one already exists
 - to prevent accidental exiting  from tmux  (later can happen
   if we unintentionally close last "**pane**" in tmux, for example
   by exiting shell with CTRL+D).

By attaching to existing tmux session, we achieve that only one session
is  running per user login.  Aka.  each new ssh to host will disconnect
active  ssh  session  (by stealing tmux session),  while preserving all
what is running in current session.  Same rule applies to console login
session, which will steal any active tmux session (being ssh or console
session).  Basically only one  tmux session can exist, and consequentially
only one login session (be it from ssh or console).

When tmux is started from terminal session (eg. from x-windows terminal),
above mentioned does not apply.


# Installation
Clone repository to your system, cd to **ltmux** directory and run:
```
sudo make install
```
This will create **ltmux** script and install it into `/usr/local/bin`
directory. Autocompletion configuration files for **bash** and **zsh**
will also be installed as part of installation process (if given shells
are installed on system). If given shell is installed afterwards, repeat
installation process to install missing autocompletion files.

You can remove **ltmux** from system by running 
```
sudo make uninstall
```


# Usage
To activate **ltmux** run:
```
ltmux enable
```
and to deactivate it:
```
ltmux disable
```
Short help can be obtained by simply running:
```
>ltmux

synopsis:
   usage: ltmux command [option]

commands:
   info                     - short info on "ltmux"

   enable                   - enable starting tmux at login
   disable                  - disable starting tmux at login
   config {install|remove}  - install/remove customized tmux
                              configuration file (.tmux.conf)
```


# Default config
With **ltmux** comes default **tmux** config, which can be installed when
**ltmux** is enabled. If rejected at the time, config can be installed
afterwards with:
```
ltmux config install
```
and later removed with
```
ltmux config remove
```
If user chooses not to install default config file, existing one will be
modified to include **exit keys** (see below). User can modified default
**exit keys** combination, but should leave the coresponding code intact.

# Modifying default config
User can freely modify default config, in any way, but if default **ltmux**
config is deleted those changes will be lost. Default config can be deleted
by issuing `ltmux config remove` or when `ltmux disable` is executed.

To prevent accidental deletion of config file, user has to change commented
line at the beginning of the file as explained in file itself. If changed
config file will be unaffected by `ltmux config remove` and `ltmux disable`.


# How it works?

When user issues:
```
ltmux enable
```
existing *login scripts* will be modified
for the invoking user.  Only **bash** and **zsh** are supported as login
shells (the one defined in `/etc/passwd` file).

Which *login script* will be modified depends on user's login shell
and the files present in user's $HOME directory. For **bash** following
files are candidates: *.bash_profil, .bash_login* and *.profile,* while
for **zsh** *.zprofile* and *.zlogin* are possible choices.  **ltmux**
will chose login script with highest precedence for given login shell
(in **bash** only one file is sourced).

If user adds or removes login script, or changes login shell, `ltmux enable`
should be invoked again.

<br>

**Starting new & attaching to running session**
<ul>

After login scripts are modified, **ltmux** will be run, whenever login
script is sourced. **ltmux** will then identify if this is fresh login
on console or via ssh connection. If so, it will attach to existing
**tmux** session, and if one does not exists it will initiate new one.
The name of the session will be: **ltmux-user_name** and should be 
kept as such, since unique name is only way for **ltmux** to identify
existing session.
</ul>

**Leaving session**
<ul>

When started, **ltmux** will create lock file, and stay in infinite loop
as long as lock file is present. Effectively preventing accidental
exits from **tmux** session. The intention is to prevent full logout from
the system, if user accidentally closes last tmux **pane** (for example 
leaving last shell by pressing CTRL+D). 

To logout from the system, lock file has to be deleted before exiting tmux
session, signaling **ltmux** that exit was intentional. This is achieved by
pressing one of the "**exit keys**" combination.
</ul>

**Exit keys**
<ul>

Following key combinations will delete **lock** file and logout from system:
```
a) prefix q
b) prefix x
```
With (a) **quitting** session, leaving running processes intact for future use,
and (b) **exiting** session, killing all running processes and destroying 
session. 

This key combination is defined in **tmux** config file: `.tmux.conf`.

When user runs `ltmux enable` he will be offered to install default **tmux**
config file. If user declines installation of default config file, existing
one will be modified to include above mentioned key combination. User can
modify given combination to suite it's needs, but should leave code associated
with keys unchanged.

("prefix" is tmux key combination defined in `.tmmux.conf` file)
</ul>

**Help I'm stuck**
<ul>

In unfortunate event that **exit keys** combination is not working, user can
initiate emergency logout from system, by ending **tmux** session 3 times in
period of 10 seconds or less (easiest way to achieve this is to press CTRL+D
in last active pane 3 times in a row). 
</ul>

# Sourcing .bashrc
Each time **tmux** creates new window or pane, it will also create new login
session. In login session bash does not automatically source **.bashrc** file,
in which most of configuration is done.

Login session sources one of the login scripts: *.bash_profile,
.bash_login or .profile*. If **.bashrc** is not explicitly sourced from those
scripts it will not be sourced at all.

For that reason, **ltmux** adds a code to login scripts it has modified, to
enable sourcing of **.bashrc** file. It also adds some code in **.bashrc**
file itself, where single variable is set, indicating that **.bashrc** has 
already been sourced, avoiding second time sourcing of **.bashrc** file.

Comments surrounding added code, should not be modified, since they are 
used to identify inserted code, and to automatically remove it when
`tmux disable` is invoked.
