#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

#################### Prompt String 1: ####################

# Default Arch-KDE-Plasma Prompt
#PS1='[\u@\h \W]\$ '

# Default Ubuntu/Debian Prompt
#PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

# Default Debian Prompt (no color)
#PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '

# Default Ubuntu/Debian Prompt (purple color)
#PS1='${debian_chroot:+($debian_chroot)}\[\033[0;35m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '


# Starship Prompt
# Edit Prompt 1 in ~/.config/starship.toml or type my alias cmd 'starship-config'
eval "$(starship init bash)"


#########################################################

# Aliases are in ~/.bash_aliases
if [ -f ~/.bash_aliases ]; then
. ~/.bash_aliases
fi




# Shows the IOMMU Groups
iommu-list() {
	for g in $(find /sys/kernel/iommu_groups/* -maxdepth 0 -type d | sort -V); do
    	echo "IOMMU Group ${g##*/}:"
    	for d in $g/devices/*; do
        	echo -e "\t$(lspci -nns ${d##*/})"
    	done;
	done;
}


# Zoxide
[[ -r "/usr/share/z/z.sh" ]] && source /usr/share/z/z.sh
