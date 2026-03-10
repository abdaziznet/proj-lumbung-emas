import 'dart:io';

void main() async {
  print("Building APK...");

  var result = await Process.run("flutter", [
    "build",
    "apk",
    "--release",
  ], runInShell: true);

  stdout.write(result.stdout);
  stderr.write(result.stderr);

  final apkPath = "build/app/outputs/flutter-apk/app-release.apk";

  if (!File(apkPath).existsSync()) {
    print("APK not found!");
    return;
  }

  final pubspec = File("pubspec.yaml").readAsStringSync();
  final regex = RegExp(r'version:\s*([^\s]+)');
  final match = regex.firstMatch(pubspec);

  if (match == null) {
    print("Version not found");
    return;
  }

  final version = match.group(1)!.replaceAll("+", "-");

  final newName = "lumbungemasku-$version.apk";

  final newPath = "build/app/outputs/flutter-apk/$newName";

  File(apkPath).renameSync(newPath);

  print("APK renamed to: $newName");
}
