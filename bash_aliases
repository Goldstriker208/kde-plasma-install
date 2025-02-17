
# Aliases 

alias ls='ls --color=auto'
alias grep='grep --color=auto'\

alias update-grub='sudo grub-mkconfig -o /boot/grub/grub.cfg'

alias alias-config='nano ~/.bash_aliases'
alias bashrc-config='nano ~/.bashrc'
alias bashrc='nano ~/.bashrc'
alias starship-config='nano ~/.config/starship.toml'


# Opens VFIO IDs file
alias vfio-ids='sudo nano /etc/modprobe.d/vfio.conf'

# IMMOU Script
alias verify-iommu='sudo dmesg | grep -i IOMMU'

# Grub user config
alias grub-config='sudo nano /etc/default/grub'

# some more ls aliases
# alias ll='ls -alF'
# alias la='ls -A'
# alias l='ls -CF'
