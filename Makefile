.PHONY: doc-serve shortcode-docs docs
.DEFAULT_GOAL := doc-serve


GH_ORG = scientific-python
TEAMS_DIR = doc/static/teams
TEAMS = theme-team
TEAMS_QUERY = python tools/team_query.py

$(TEAMS_DIR):
	mkdir -p $(TEAMS_DIR)

$(TEAMS_DIR)/%.md: $(TEAMS_DIR)
	$(eval TEAM_NAME=$(shell python -c "import re; print(' '.join(x.capitalize() for x in re.split('-|_', '$*')))"))
	$(TEAMS_QUERY) --org $(GH_ORG) --team "$*"  >  $(TEAMS_DIR)/$*.html

teams-clean:
	for team in $(TEAMS); do \
	  rm -f $(TEAMS_DIR)/$${team}.html ;\
	done

teams: | teams-clean $(patsubst %,$(TEAMS_DIR)/%.md,$(TEAMS))

doc/content/shortcodes.md: $(wildcard layouts/shortcodes/*.html)
	python tools/render_shortcode_docs.py > doc/content/shortcodes.md

# Serve for development purposes.
doc-serve: doc/content/shortcodes.md
	(cd doc && hugo --printI18nWarnings serve --themesDir="../.." --disableFastRender --poll 1000ms)

docs: doc/content/shortcodes.md
	(cd doc ; hugo --themesDir="../..")

theme: doc/content/shortcodes.md
	(cd .. ; ln -s repo scientific-python-hugo-theme)
	(cd doc ; hugo --themesDir="../..")
