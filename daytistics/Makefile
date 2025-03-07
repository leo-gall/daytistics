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

run-functions:
	supabase functions serve --env-file=./supabase/.env

https://play.google.com/apps/internaltest/4699890422551366748