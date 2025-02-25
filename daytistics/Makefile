analyze-all:
	flutter analyze
	dart run custom_lint
	deno lint

analyze-flutter:
	flutter analyze
	dart run custom_lint

analyze-supabase:
	deno lint

test-all:
	flutter test
	deno test --env-file=./.env --allow-all 

test-flutter:
	flutter test

test-supabase:
	deno test --env-file=./.env --allow-all

all:
	make analyze-all
	make test-all