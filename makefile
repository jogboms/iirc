xcode:
	open ios/Runner.xcworkspace

ci:
	make format && make analyze && make test_coverage

format:
	fvm flutter format --set-exit-if-changed -l 120 lib

analyze:
	fvm flutter analyze lib

test_coverage:
	fvm flutter test --no-pub --coverage

build_coverage:
	make test_coverage && genhtml -o coverage coverage/lcov.info

open_coverage:
	make build_coverage && open coverage/index.html

generate_intl:
	fvm flutter packages pub run intl_utils:generate

build_runner_build:
	fvm flutter packages pub run build_runner build --delete-conflicting-outputs

build_runner_watch:
	fvm flutter packages pub run build_runner watch --delete-conflicting-outputs

# iOS
mock_ios:
	fvm flutter build ios --flavor mock --dart-define=env.mode=mock

dev_ios:
	fvm flutter build ios --flavor dev --dart-define=env.mode=dev

prod_ios:
	fvm flutter build ios --flavor prod --dart-define=env.mode=prod

# Android
mock_android:
	fvm flutter build apk --flavor mock --dart-define=env.mode=mock

dev_android:
	fvm flutter build apk --flavor dev --dart-define=env.mode=dev

prod_android:
	fvm flutter build apk --flavor prod --dart-define=env.mode=prod

prod_android_bundle:
	fvm flutter build appbundle --flavor prod --dart-define=env.mode=prod
