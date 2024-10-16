# Dotfiles

Project forked from shmileee/dotfiles.

Fully automated development environment. Read the full documentation
[here](https://oponomarov.com).


## Installation

We are assuming it will be installed in a clean Ubuntu installation, and that `wget` is available, but you can download `setup.sh` in several other ways.
Remember to review the script before running it, as you will need to use `sudo` to install some stuff.

```bash
wget https://raw.githubusercontent.com/marandra/dotfiles/refs/heads/master/scripts/setup.sh
bash setup.sh --all
```

## Installation Flow

```
   ┌────────────────────────────────────────────┐
┌──┤wget .../scritps/setup.sh; sh setup.sh --all│
│  └────────────────────────────────────────────┘
│
│
│     ┌─────────────────────────────────────┐
├───► │git clone marandra/dotfiles.git /tmp │
│     └─────────────────────────────────────┘
│
│     ┌─────────────────────────┐     ┌──────────────────────────┐
├───► │./install_dependencies.sh├────►│ apt install <essentials> │
│     └─────────────────────────┘     └──────────────────────────┘
│
│     ┌──────────────────┐
├───► │./install_brew.sh │
│     └──────────────────┘
│
│     ┌────────────┐
└───► │./ansible.sh│
      └─────┬──────┘
            │
   ┌────────┘
   │
   │  ┌─────────────────────────┐
   ├─►│install community.general│
   │  └─────────────────────────┘
   │
   │  ┌──────────────────────────┐
   │  │ prompt for password if   │
   ├─►│ sudo is not passwordless │
   │  └──────────────────────────┘
   │
   │
   │  ┌───────────────────────────────┐
   └─►│ansible-playbook ... main.yaml │
      └───────────────┬───────────────┘
                      │
     ┌────────────────┘
     │                 ┌────────────────────────┐
     │  ┌──────┐       │ brew install <packages>│
     ├─►│common├──────►│ brew install <casks>   │
     │  └──────┘       └────────────────────────┘
     │
     │  ┌───────┐
     ├─►│ fonts │
     │  └───────┘
     │                 ┌───────────────┐
     │  ┌──────────┐   │ chezmoi init  │
     ├─►│ dotfiles ├──►│ chezmoi update│
     │  └──────────┘   └───────────────┘
     │
     │
     │
     │  ┌────┐         ┌────────────────────┐
     ├─►│fish├───────┐ │change default shell│
     │  └────┘       └►│install fisher      │
     │                 │install fish plugins│
     │                 └────────────────────┘
     │
     │
     │                 ┌──────────────────────┐
     │  ┌──────┐       │ either:              │
     ├─►│neovim├──────►│  - build from source │
     │  └──────┘       │  - install binary    │
     │                 └──────────────────────┘
     │
     │
     │                 ┌───────────────────────────┐
     │  ┌────────┐     │ download                  │
     ├─►│lunarvim├────►│ install                   │
     │  └────────┘     │ update config with chezmoi│
     │                 └───────────────────────────┘
     │
     │
     │                 ┌────────────────────┐
     │  ┌────┐         │ install plugins    │
     ├─►│asdf├────────►│ install tools      │
     │  └────┘         │ set global versions│
     │                 └────────────────────┘
     │
     │  ┌────┐         ┌────────────────────┐
     ├─►│ go ├────────►│ install go packages│
     │  └────┘         └────────────────────┘
     │
     │  ┌────────┐
     ├─►│ docker │
     │  └────────┘     ┌──────────────────────┐
     │                 │install plugin manager│
     │  ┌──────┐    ┌─►│install plugins       │
     ├─►│ tmux ├────┘  └──────────────────────┘
     │  └──────┘
     │
     │  ┌─────────────────┐
     └─►│ system_defaults │
        └───────┬─────────┘
                │          ┌───────────────────────────────┐
                ├─────────►│ defaults write <apps settings>│
                │          └───────────────────────────────┘
                │
                │          ┌────────────────────┐
                ├─────────►│reorder apps in dock│
                │          └────────────────────┘
                │
                │          ┌──────────────────────┐
                ├─────────►│set custom keybindings│
                │          └──────────────────────┘
                │
                │          ┌───────────────────────┐
                └─────────►│defaults write <system>│
                           └───────────────────────┘
```

## Credits

Many thanks to the [dotfiles community](https://dotfiles.github.io).
