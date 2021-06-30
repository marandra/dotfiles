#!/usr/bin/env fish

#######################################################################
#                               General                               #
#######################################################################

# source fzf binds
fzf_key_bindings

#######################################################################
#                               Aliases                               #
#######################################################################

if which subl &>/dev/null
   alias s subl
end

alias g git
alias ls exa
alias tx tmuxinator
alias du duf
alias groot 'git rev-parse --show-toplevel'
alias r 'source ~/.config/fish/config.fish'
alias ssh 'assh wrapper ssh --'
alias p 'cd ~/projects'
alias w 'cd ~/work'
alias d 'cd ~/dotfiles'
alias gdc 'git diff --cached | vim -'
alias tree 'tree -a -I ".git|*.pyc|*pycache*"'
alias cdp 'cd (git rev-parse --show-toplevel)'
alias vdt="rm /tmp/%*" # Remove Vim's temp file
alias vss="sort -u ~/.vim/spell/en.utf-8.add -o ~/.vim/spell/en.utf-8.add"
alias dps 'docker ps' # Get container process
alias dpa 'docker ps -a' # Get process included stop container
alias dip 'docker inspect --format "{{ .NetworkSettings.IPAddress }}"' # Get container IP
alias dkd 'docker run -d -P' # Run deamonized container, e.g., $dkd base /bin/echo hello
alias dki 'docker run -i -t -P' # Run interactive container, e.g., $dki base /bin/bash
alias dex 'docker exec -i -t' # Execute interactive container, e.g., $dex base /bin/bash

#######################################################################
#                          Windows-specific                           #
#######################################################################

if grep -qE "(Microsoft|WSL)" /proc/version &>/dev/null
  if [ (umask) = "0000" ]
    umask 0022
  end

  set -gx DOCKER_HOST "tcp://localhost:2375"
  # fixing volumes not working in WSL1
  set -gx ROOTFS_DIR (echo "/c/Users/oleksandrp/AppData/Local\
    /Packages/CanonicalGroupLimited.Ubuntu20.04onWindows_79rhkp1fndgsc\
    /LocalState/rootfs" | sed '/^$/d;s/[[:blank:]]//g')

  function proxy
    if [ -f ~/.proxy ]
       rm ~/.proxy
       rm ~/.gitconfig.proxy
    else
       ln -s ~/dotfiles/.proxy ~/.proxy
       ln -s ~/dotfiles/.gitconfig.proxy ~/.gitconfig.proxy
    end
  end

  function open
   '/c/Program Files (x86)/Google/Chrome/Application/chrome.exe' $argv
  end

  function dnsfix
    set -lx search (grep -F "search" /etc/resolv.conf)
    set -lx ipv4dnsraw (/c/Windows/system32/netsh.exe \
       interface ip show dns | tr -d '\r');
    set -lx ipv6dnsraw (/c/Windows/system32/netsh.exe \
       interface ipv6 show dns | tr -d '\r');
    set -lx nameservers (printf '%s\n%s\n' \
       $ipv4dnsraw $ipv6dnsraw | grep -iF "DNS Servers" | grep -v "None" \
       | cut -c 43- |  uniq | sed 's/^/nameserver /')
    printf '%s on %s\n%s\n%s\n' '# generated by dnsfix' (date) \
       $nameservers $search | sudo tee /etc/resolv.conf >/dev/null;
  end

  # https://github.com/yuk7/ArchWSL/issues/109
  alias rg "rg -j1 --hidden -i"

  set -gx PATH "/c/Program\ Files/Oracle/VirtualBox" $PATH

  # Source corporate proxy if exists
  if [ -f ~/.proxy ]; . \
    ~/.proxy; end

    # Fix DNS when connecting through VPN
    dnsfix
end

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/esolidarity/google-cloud-sdk/path.fish.inc' ]; . \
   '/Users/esolidarity/google-cloud-sdk/path.fish.inc'; end

#######################################################################
#                               Exports                               #
#######################################################################

set -gx EDITOR "vim"

set -gx FZF_DEFAULT_COMMAND "rg --files --hidden --follow --glob '!.git'"
set -gx FZF_DEFAULT_OPTS "--color=dark"

set -gx GOPATH ~/go
set -gx GOBIN "$GOPATH/bin"
set -gx PATH "$GOBIN" $PATH
set -gx PATH "/opt/homebrew/bin" $PATH
set -gx PATH "/opt/homebrew/opt/coreutils/libexec/gnubin" $PATH
set -gx PATH ~/.local/bin $PATH
set -gx PATH ~/bin $PATH

set -gx  DISPLAY :0

#######################################################################
#                               Functions                             #
#######################################################################

function fif --description="Using ripgrep combined with preview"
   if test (count $argv) -lt 1; or test $argv[1] = "--help"
      printf "Need a string to search for."
   else if test (count $argv) -eq 1
      rg --files-with-matches --no-messages "$argv[1]" | fzf --preview \
         "highlight -O ansi -l {} 2> /dev/null | rg --colors 'match:bg:yellow' \
         --ignore-case --pretty --context 10 '$argv[1]' || rg --ignore-case \
         --pretty --context 10 '$argv[1]' {}"
   end
end

function vdiff --description="Compare two files or dirs with vim"
   if test (count $argv) -ne 2; or test $argv[1] = "--help"
      printf "vdiff requires two arguments"
      printf "  comparing dirs:  vdiff dir_a dir_b"
      printf "  comparing files: vdiff file_a file_b"
   else
      set --local left "$argv[1]"
      set --local right "$argv[2]"

      if [ -d "$left" ] && [ -d "$right" ]
          vim +"DirDiff $left $right"
      else
          vim -d "$left" "$right"
      end
    end
 end

function sudo
    if test "$argv" = !!
        eval command sudo $history[1]
    else
        command sudo $argv
    end
end

function dstop --description="Stop all containers"
    docker stop (docker ps -a -q)
end

function drm --description="Remove all containers"
    docker rm (docker ps -a -q)
end

function drmf --description="Stop and Remove all containers"
    docker stop (docker ps -a -q) && docker rm (docker ps -a -q)
end

function drmi --description="Remove all images"
    docker rmi (docker images -q)
end

function dbash --description="Bash into running container"
    if test (count $argv) -lt 1; or test $argv[1] = "--help"
      printf "Need a container name to bash into."
    else if test (count $argv) -eq 1
      docker exec -it (docker ps -aqf "name=$argv[1]") bash
    end
end

set -x LS_COLORS "no=00;38;5;244:rs=0:di=1;38;5;33:ln=00;38;5;37:mh=00:pi=48;5;230;38;5;136;01:so=48;5;230;38;5;136;01:do=48;5;230;38;5;136;01:bd=48;5;230;38;5;244;01:cd=48;5;230;38;5;244;01:or=48;5;235;38;5;160:su=48;5;160;38;5;230:sg=48;5;136;38;5;230:ca=30;41:tw=48;5;64;38;5;230:ow=48;5;235;38;5;33:st=48;5;33;38;5;230:ex=00;38;5;64:*.tar=00;38;5;61:*.tgz=00;38;5;61:*.arj=00;38;5;61:*.taz=00;38;5;61:*.lzh=00;38;5;61:*.lzma=00;38;5;61:*.tlz=00;38;5;61:*.txz=00;38;5;61:*.zip=00;38;5;61:*.z=00;38;5;61:*.Z=00;38;5;61:*.dz=00;38;5;61:*.gz=00;38;5;61:*.lz=00;38;5;61:*.xz=00;38;5;61:*.bz2=00;38;5;61:*.bz=00;38;5;61:*.tbz=00;38;5;61:*.tbz2=00;38;5;61:*.tz=00;38;5;61:*.deb=00;38;5;61:*.rpm=00;38;5;61:*.jar=00;38;5;61:*.rar=00;38;5;61:*.ace=00;38;5;61:*.zoo=00;38;5;61:*.cpio=00;38;5;61:*.7z=00;38;5;61:*.rz=00;38;5;61:*.apk=00;38;5;61:*.gem=00;38;5;61:*.jpg=00;38;5;136:*.JPG=00;38;5;136:*.jpeg=00;38;5;136:*.gif=00;38;5;136:*.bmp=00;38;5;136:*.pbm=00;38;5;136:*.pgm=00;38;5;136:*.ppm=00;38;5;136:*.tga=00;38;5;136:*.xbm=00;38;5;136:*.xpm=00;38;5;136:*.tif=00;38;5;136:*.tiff=00;38;5;136:*.png=00;38;5;136:*.PNG=00;38;5;136:*.svg=00;38;5;136:*.svgz=00;38;5;136:*.mng=00;38;5;136:*.pcx=00;38;5;136:*.dl=00;38;5;136:*.xcf=00;38;5;136:*.xwd=00;38;5;136:*.yuv=00;38;5;136:*.cgm=00;38;5;136:*.emf=00;38;5;136:*.eps=00;38;5;136:*.CR2=00;38;5;136:*.ico=00;38;5;136:*.tex=00;38;5;245:*.rdf=00;38;5;245:*.owl=00;38;5;245:*.n3=00;38;5;245:*.ttl=00;38;5;245:*.nt=00;38;5;245:*.torrent=00;38;5;245:*.xml=00;38;5;245:*Makefile=00;38;5;245:*Rakefile=00;38;5;245:*Dockerfile=00;38;5;245:*build.xml=00;38;5;245:*rc=00;38;5;245:*1=00;38;5;245:*.nfo=00;38;5;245:*README=00;38;5;245:*README.txt=00;38;5;245:*readme.txt=00;38;5;245:*.md=00;38;5;245:*README.markdown=00;38;5;245:*.ini=00;38;5;245:*.yml=00;38;5;245:*.cfg=00;38;5;245:*.conf=00;38;5;245:*.h=00;38;5;245:*.hpp=00;38;5;245:*.c=00;38;5;245:*.cpp=00;38;5;245:*.cxx=00;38;5;245:*.cc=00;38;5;245:*.objc=00;38;5;245:*.sqlite=00;38;5;245:*.go=00;38;5;245:*.sql=00;38;5;245:*.csv=00;38;5;245:*.log=00;38;5;240:*.bak=00;38;5;240:*.aux=00;38;5;240:*.lof=00;38;5;240:*.lol=00;38;5;240:*.lot=00;38;5;240:*.out=00;38;5;240:*.toc=00;38;5;240:*.bbl=00;38;5;240:*.blg=00;38;5;240:*~=00;38;5;240:*#=00;38;5;240:*.part=00;38;5;240:*.incomplete=00;38;5;240:*.swp=00;38;5;240:*.tmp=00;38;5;240:*.temp=00;38;5;240:*.o=00;38;5;240:*.pyc=00;38;5;240:*.class=00;38;5;240:*.cache=00;38;5;240:*.aac=00;38;5;166:*.au=00;38;5;166:*.flac=00;38;5;166:*.mid=00;38;5;166:*.midi=00;38;5;166:*.mka=00;38;5;166:*.mp3=00;38;5;166:*.mpc=00;38;5;166:*.ogg=00;38;5;166:*.opus=00;38;5;166:*.ra=00;38;5;166:*.wav=00;38;5;166:*.m4a=00;38;5;166:*.axa=00;38;5;166:*.oga=00;38;5;166:*.spx=00;38;5;166:*.xspf=00;38;5;166:*.mov=00;38;5;166:*.MOV=00;38;5;166:*.mpg=00;38;5;166:*.mpeg=00;38;5;166:*.m2v=00;38;5;166:*.mkv=00;38;5;166:*.ogm=00;38;5;166:*.mp4=00;38;5;166:*.m4v=00;38;5;166:*.mp4v=00;38;5;166:*.vob=00;38;5;166:*.qt=00;38;5;166:*.nuv=00;38;5;166:*.wmv=00;38;5;166:*.asf=00;38;5;166:*.rm=00;38;5;166:*.rmvb=00;38;5;166:*.flc=00;38;5;166:*.avi=00;38;5;166:*.fli=00;38;5;166:*.flv=00;38;5;166:*.gl=00;38;5;166:*.m2ts=00;38;5;166:*.divx=00;38;5;166:*.webm=00;38;5;166:*.axv=00;38;5;166:*.anx=00;38;5;166:*.ogv=00;38;5;166:*.ogx=00;38;5;166:"
