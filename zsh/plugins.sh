# This is a script to bootsrap omz with some custom plugins,
# ideally this script should only execute in its entirety once.

# no need to keep executing this script if the dir exists
if [[ -d ${ZSH_CUSTOM}/plugins ]]; then
    return
fi

github_plugins=(
    zsh-users/zsh-autosuggestions
    zsh-users/zsh-syntax-highlighting
)

for plugin in "${github_plugins[@]}"; do
  repo_name=${plugin#*/}

  if [[ ! -d ${ZSH_CUSTOM}/plugins/$repo_name ]]; then
    mkdir -p ${ZSH_CUSTOM}/plugins
    git clone --depth 1 --recursive https://github.com/$plugin.git ${ZSH_CUSTOM}/plugins/$repo_name
  fi

  # loads plugin after cloning
  for initscript in "$repo_name.zsh" "$repo_name.plugin.zsh" "$repo_name.sh"; do
    if [[ -f ${ZSH_CUSTOM}/plugins/$repo_name/$initscript ]]; then
      source "${ZSH_CUSTOM}/plugins/$repo_name/$initscript"
      break
    fi
  done
done

# cleanup
unset github_plugins
unset plugin
unset repo_name
unset initscript
