.PHONY: stow unstow restow help secrets secrets-edit secrets-restore-key

# Stow packages with dotfiles support
STOW_FLAGS = --dotfiles -v
PACKAGES = bash bzrk claude-skills git hypr keyboard nvim wireplumber

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
	@./scripts/safe-stow.sh $(PACKAGES)
	@$(MAKE) --no-print-directory secrets

unstow:
	stow -D $(STOW_FLAGS) $(PACKAGES)

restow:
	stow -R $(STOW_FLAGS) $(PACKAGES)

secrets:
	@if [ ! -f ~/.config/sops/age/keys.txt ]; then \
		echo "Skipping secrets: age key not found at ~/.config/sops/age/keys.txt"; \
		echo "  Run 'pass-cli login && make secrets-restore-key' to restore it,"; \
		echo "  then re-run 'make secrets'."; \
	else \
		echo "Decrypting secrets to ~/.secrets..."; \
		sops decrypt --input-type dotenv --output-type dotenv secrets.enc.env \
			| sed 's/^/export /' > ~/.secrets.tmp \
			&& mv ~/.secrets.tmp ~/.secrets \
			&& chmod 600 ~/.secrets \
			&& echo "Done." \
			|| { rm -f ~/.secrets.tmp; echo "Decryption failed."; exit 1; }; \
	fi

secrets-edit:
	EDITOR=$${EDITOR:-nvim} sops edit --input-type dotenv --output-type dotenv secrets.enc.env

secrets-restore-key:
	@mkdir -p ~/.config/sops/age
	@PUB=$$(pass-cli item view --vault-name Personal --item-title "SOPS Age Private Key (Master)" --field username) && \
	 KEY=$$(pass-cli item view --vault-name Personal --item-title "SOPS Age Private Key (Master)" --field password) && \
	 printf '# public key: %s\n%s\n' "$$PUB" "$$KEY" > ~/.config/sops/age/keys.txt
	@chmod 600 ~/.config/sops/age/keys.txt
	@echo "Age key restored from Proton Pass."
