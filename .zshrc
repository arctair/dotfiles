# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=/usr/share/oh-my-zsh

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS=true

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git ssh-agent)

source $ZSH/oh-my-zsh.sh
if [ -f /usr/share/nvm/init-nvm.sh ] ; then
  source /usr/share/nvm/init-nvm.sh
fi
source ~/.zsh_secrets

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"
if [ -f /usr/share/camlink/camlink.so ] ; then
  export LD_PRELOAD="$LD_PRELOAD /usr/share/camlink/camlink.so"
fi
if [ -f /usr/share/nvm/init-nvm.sh ] ; then
  source /usr/share/nvm/init-nvm.sh
fi
export LD_LIBRARY_PATH=$HOME/.local/lib
export GOPATH=$HOME/ws/go
export GOBIN=$GOPATH/bin
export YARNPATH=$HOME/.yarn
export OBSPATH=$HOME/.local/share/obs-studio-portable
export PATH="$PATH:$GOBIN:$YARNPATH/bin:$HOME/.local/bin:$OBSPATH/bin/64bit"
export GROOVY_TURN_OFF_JAVA_WARNINGS=true

# git
git config --global push.default current
git config --global user.name tyler
git config --global user.email tyler@cruftbusters.com
git config --global pull.rebase true
git config --global init.defaultBranch main

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
# Configuration
export KUBE_EDITOR="vim"
# Aliases
alias ys="BROWSER=none yarn start"
alias yt="yarn test"
alias yat="yarn acceptanceTest"
alias gomon='nodemon -e go --exec "go test || exit 1"'
# Functions
## Development
wip() {
  if [[ `current_branch` != wip/* ]] ; then
    git checkout -b wip/`current_branch`
  fi
  git add --all
  git commit -m wip
}
unwip() {
  if [[ `current_branch` != wip/* ]] ; then
    echo not on wip branch
    return
  fi
  git checkout $(echo `current_branch` | sed 's/^wip\///')
  git merge wip/`current_branch` --squash
  git branch -D wip/`current_branch`
}
createRepository() {
  curl -sXPOST \
    https://api.github.com/user/repos \
    -u arctair:$GITHUB_TOKEN \
    -d "{\"name\":\"$1\"}" ;
}
createOrgRepository() {
  response=`curl -sXPOST \
    https://api.github.com/orgs/$1/repos \
    -u arctair:$GITHUB_TOKEN \
    -d "{\"name\":\"$2\"}"`
  if ! git remote get-url origin ; then
    git remote add origin `echo $response | jq .ssh_url -r`
  fi
}
jsconfig() { echo '{"compilerOptions":{"baseUrl":"src"}}' | jq . ; }
nginx() { docker run --rm --name nginx-ephemeral -v ${1:-$(pwd)}:/usr/share/nginx/html:ro -p 80:80 nginx-static ; }
uriencode () { node -e "console.log(encodeURIComponent('$1'))" ; }
uuidcopy() { uuidgen | tr -d '\n-' | xclip -sel clip ; }
versionByDepth() { echo v${1:-0}.${2:-0}.`git rev-list --count HEAD` ; }
tagByDepth() {
  git tag `versionByDepth $1 $2`
  git push origin `versionByDepth $1 $2`
}
## Timelapse
timelapse() {
ffmpeg -r $1 \
  -start_number $2 \
  -i $3 \
  -s 1080x1080 \
  -crf 18 \
  -c:v libx264 \
  -preset slow \
  -profile:v baseline \
  -level 3.0 \
  -movflags +faststart \
  -pix_fmt yuv420p \
  -c:a aac \
  -b:a 128k \
  $4 ;
}
## Streaming
loopback() {
  loopbacks=(`v4l2-ctl --list-device | grep v4l2loopback -A 1 | grep -v v4l2loopback | grep /dev | tr -d $'\t' | tr '\n' ' '`)
  echo ${loopbacks[$1]}
}
camlink() {
  v4l2-ctl --list-device | grep 'Cam Link' -A 1 | grep -v 'Cam Link' | tr -d $'\t'
}
configureSwitchStream() {
  xrandr --output DP1 --above eDP1 --output eDP1 --mode 1920x1080
  if [[ "`loopback 1`" == '' ]] ; then
    sudo modprobe v4l2loopback devices=2 exclusive_caps=1
  fi
  ffmpeg -nostdin -f v4l2 -input_format yuyv422 -video_size 1920x1080 -i `camlink` -pix_fmt yuyv422 -codec copy -f v4l2 `loopback 1` -pix_fmt yuyv422 -codec copy -f v4l2 `loopback 2` & ffmpegPid=$!
  sleep 1
  mplayer tv:// -tv driver=v4l2:device=`loopback 1`
  kill $ffmpegPid
  xrandr --output DP1 --off --output eDP1 --pos 0x0 --mode 3200x1800
}


# hellish AWS
lookup-hosted-zone-id() {
  aws route53 list-hosted-zones | jq ".HostedZones[]|select(.Name==\"$1.\")|.Id" -r
}
upsert-resource-record-set() {
  # upsert-resource-record-set <hosted-zone-id> <resource-record-set-name> <type> <ttl> <value>
  resourceRecordSet="`jq -nc \
    --arg name "$2" \
    --arg type "$3" \
    --argjson ttl $4 \
    --arg value "$5" \
    '{Name:$name,Type:$type,TTL:$ttl,ResourceRecords:[{Value:$value}]}'`"
  upsert="`jq -nc \
    --argjson resourceRecordSet "$resourceRecordSet" \
    '{Changes:[{Action:"UPSERT",ResourceRecordSet:$resourceRecordSet}]}'`"
  aws route53 change-resource-record-sets \
    --hosted-zone-id $1 \
    --change-batch $upsert
}
upsert-cname() {
  # upsert-srv <hosted-zone-id> <resource-record-set-name> <value>
  upsert-resource-record-set $1 $2 CNAME 300 $3
}
upsert-srv() {
  # upsert-srv <hosted-zone-id> <resource-record-set-name> <port> <target>
  upsert-resource-record-set $1 $2 SRV 300 "10 5 $3 $4"
}
update-distribution-origin-https-port() {
  distribution="`aws cloudfront get-distribution --id $1 | jq -c`"
  distributionConfig=
  update="`jq -nc \
    --arg ifMatch "$(echo $distribution | jq .ETag -r)" \
    --argjson distributionConfig "$(echo $distribution | jq .Distribution.DistributionConfig -c)" \
    --argjson httpsPort $2 \
    '{IfMatch:$ifMatch,DistributionConfig:$distributionConfig}|.DistributionConfig.Origins.Items[].CustomOriginConfig.HTTPSPort=$httpsPort'`"
  aws cloudfront update-distribution \
    --id $1 \
    --cli-input-json $update
}

# yagni nonsense
get-ngrok-uri-by-port() {
  ssh yagni -- screen -S ngrok -X hardcopy /tmp/ngrok-dump
  ssh yagni -- grep :$1$ /tmp/ngrok-dump | tr -s ' ' | cut -d ' ' -f2
}
update-mommyfactory-dns() {
  hostedZoneID=`lookup-hosted-zone-id bingecraft.net`
  uri=`get-ngrok-uri-by-port 25565`
  host=`echo $uri | cut -d / -f3- | cut -d : -f1`
  port=`echo $uri | cut -d / -f3- | cut -d : -f2`
  upsert-cname $hostedZoneID mommyfactory.bingecraft.net $host
  upsert-srv $hostedZoneID _minecraft._tcp.bingecraft.net $port mommyfactory.bingecraft.net
}
update-ngrok-front() {
  uri=`get-ngrok-uri-by-port 443`
  host=`echo $uri | cut -d / -f3- | cut -d : -f1`
  port=`echo $uri | cut -d / -f3- | cut -d : -f2`
  upsert-cname `lookup-hosted-zone-id cruftbusters.com` ngrok.cruftbusters.com $host
  update-distribution-origin-https-port E27EUM29AENB82 $port
}
update-ngrok-ssh() {
  uri=`get-ngrok-uri-by-port 22`
  host=`echo $uri | cut -d / -f3- | cut -d : -f1`
  port=`echo $uri | cut -d / -f3- | cut -d : -f2`
  cat <<EOF > ~/.ssh/yagni-config
Host yagni
  HostName $host
  Port $port
EOF
}
