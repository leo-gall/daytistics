analyze-all:
	flutter analyze
	dart run custom_lint
	deno lint

analyze-flutter:
	flutter analyze
	dart run custom_lint

analyze-deno:
	deno lint

test-all:
	flutter test
	deno test --env-file=./.env --allow-all 

test-flutter:
	flutter test

test-deno:
	deno test --env-file=./.env --allow-all

run-functions:
	supabase functions serve --env-file=./.env