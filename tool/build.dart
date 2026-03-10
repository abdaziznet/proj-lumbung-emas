import 'dart:io';

void main() async {
  print("🔨 Build Script - Auto Version Increment");
  print("=" * 50);

  // Step 1: Check for code changes using git
  final gitStatus = await Process.run("git", [
    "status",
    "--porcelain",
  ], runInShell: true);
  final hasChanges = (gitStatus.stdout as String).isNotEmpty;

  if (hasChanges) {
    print("✓ Code changes detected - incrementing version...");
    await _incrementVersion();
  } else {
    print("✓ No code changes detected - keeping current version");
  }

  // Step 2: Build APK
  print("\n📦 Building APK...");
  var result = await Process.run("flutter", [
    "build",
    "apk",
    "--release",
  ], runInShell: true);

  stdout.write(result.stdout);
  stderr.write(result.stderr);

  // Step 3: Rename APK with version
  final apkPath = "build/app/outputs/flutter-apk/app-release.apk";

  if (!File(apkPath).existsSync()) {
    print("❌ APK not found!");
    return;
  }

  final pubspec = File("pubspec.yaml").readAsStringSync();
  final regex = RegExp(r'version:\s*([^\s]+)');
  final match = regex.firstMatch(pubspec);

  if (match == null) {
    print("❌ Version not found");
    return;
  }

  final version = match.group(1)!.replaceAll("+", "-");
  final newName = "lumbungemasku-$version.apk";
  final newPath = "build/app/outputs/flutter-apk/$newName";

  File(apkPath).renameSync(newPath);

  print("\n✅ APK renamed to: $newName");
  print("=" * 50);
}

Future<void> _incrementVersion() async {
  final pubspecFile = File("pubspec.yaml");
  final pubspec = pubspecFile.readAsStringSync();

  // Parse current version: YYYY.MAJOR.MINOR+BUILD
  final regex = RegExp(r'version:\s*(\d{4})\.(\d+)\.(\d+)\+(\d+)');
  final match = regex.firstMatch(pubspec);

  if (match == null) {
    print("❌ Invalid version format in pubspec.yaml");
    return;
  }

  final year = match.group(1)!;
  final major = match.group(2)!;
  final minor = int.parse(match.group(3)!);
  final build = int.parse(match.group(4)!);

  // Increment minor version + reset build
  final newMinor = minor + 1;
  final newBuild = 1;
  final newVersion = "$year.$major.$newMinor+$newBuild";

  // Update pubspec.yaml
  final updatedPubspec = pubspec.replaceFirst(regex, "version: $newVersion");

  pubspecFile.writeAsStringSync(updatedPubspec);
  print("  Version: ${match.group(0)} → $newVersion");
}
