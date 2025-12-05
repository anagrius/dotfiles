.PHONY: stow unstow restow help

# Stow packages with dotfiles support
STOW_FLAGS = --dotfiles -v
PACKAGES = bash hypr keyboard nvim

help:
	@echo "Dotfiles Management"
	@echo "==================="
	@echo "make stow      - Install all dotfiles"
	@echo "make unstow    - Remove all dotfiles"
	@echo "make restow    - Reinstall all dotfiles"
	@echo ""
	@echo "Packages: $(PACKAGES)"

stow:
	stow $(STOW_FLAGS) $(PACKAGES)

unstow:
	stow -D $(STOW_FLAGS) $(PACKAGES)

restow:
	stow -R $(STOW_FLAGS) $(PACKAGES)
