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

release-ios:
	sudo chmod -R 777 . && flutter pub get && cd ios && bundle install && bundle exec pod repo update && bundle exec pod install && cd .. && flutter clean && cd ios && fastlane release_app_store