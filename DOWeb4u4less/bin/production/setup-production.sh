#! bin/bash

# append -K to this command if using a non-root sudo user
# (i.e., if using with the security role)
# append --ask-vault-pass to this command if
# using ansible-vault to encrypt ../group_vars/vault.yml.
ansible-playbook -i production site.yml  #--ask-vault-pass
