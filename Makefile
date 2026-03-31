.PHONY: stow unstow restow help secrets secrets-edit secrets-restore-key

# Stow packages with dotfiles support
STOW_FLAGS = --dotfiles -v
PACKAGES = bash git hypr keyboard nvim wireplumber

help:
	@echo "Dotfiles Management"
	@echo "==================="
	@echo "make stow         - Install all dotfiles + decrypt secrets"
	@echo "make unstow       - Remove all dotfiles"
	@echo "make restow       - Reinstall all dotfiles"
	@echo "make secrets      - Decrypt secrets.enc.env to ~/.secrets"
	@echo "make secrets-edit - Edit secrets (decrypts, opens editor, re-encrypts)"
	@echo "make secrets-restore-key - Restore age key from pass"
	@echo ""
	@echo "Packages: $(PACKAGES)"

stow:
	stow $(STOW_FLAGS) $(PACKAGES)
	@$(MAKE) --no-print-directory secrets

unstow:
	stow -D $(STOW_FLAGS) $(PACKAGES)

restow:
	stow -R $(STOW_FLAGS) $(PACKAGES)

secrets:
	@echo "Decrypting secrets to ~/.secrets..."
	@sops decrypt --input-type dotenv --output-type dotenv secrets.enc.env | sed 's/^/export /' > ~/.secrets
	@chmod 600 ~/.secrets
	@echo "Done."

secrets-edit:
	EDITOR=$${EDITOR:-nvim} sops edit --input-type dotenv --output-type dotenv secrets.enc.env

secrets-restore-key:
	@mkdir -p ~/.config/sops/age
	@PUB=$$(pass-cli item view --vault-name Personal --item-title "SOPS Age Private Key (Master)" --field username) && \
	 KEY=$$(pass-cli item view --vault-name Personal --item-title "SOPS Age Private Key (Master)" --field password) && \
	 printf '# public key: %s\n%s\n' "$$PUB" "$$KEY" > ~/.config/sops/age/keys.txt
	@chmod 600 ~/.config/sops/age/keys.txt
	@echo "Age key restored from Proton Pass."
