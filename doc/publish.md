# Publish the project to pub.dev

[ ] Perform unittests
[ ] Update documentation
[ ] Format source

    flutter format .

[ ] Increase version in pubspec.yaml
[ ] Analyze package quality with pana (https://pub.dev/packages/pana)

    flutter pub global activate pana
    pana

(git must be installed and accessible via path)

[ ] flutter publish dry run

    dart pub publish --dry-run

[ ] Checkin into git
[ ] Create a tag for the new version
[ ] flutter publish

    dart pub publish

Watch thousands of users downloading the project :-)
