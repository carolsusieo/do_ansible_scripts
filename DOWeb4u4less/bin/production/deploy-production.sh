#! bin/bash

# append --ask-vault-pass to this command if
# using ansible-vault to encrypt ../group_vars/vault.yml
ansible-playbook -i production site.yml --tags=deploy #--ask-vault-pass
