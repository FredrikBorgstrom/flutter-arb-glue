# ARB Glue

[![codecov](https://codecov.io/gh/evan361425/flutter-arb-glue/graph/badge.svg?token=Y85VgUOsWZ)](https://codecov.io/gh/evan361425/flutter-arb-glue)
[![Codacy Badge](https://app.codacy.com/project/badge/Grade/09d8ff1bbd3741499c1680a68897a9cf)](https://app.codacy.com/gh/evan361425/flutter-arb-glue/dashboard)
[![Pub Version](https://img.shields.io/pub/v/spotlight_ant)](https://pub.dev/packages/arb_glue)

ARB Glue is a tool that merges multiple files into one single [ARB] format file,
facilitating the management of internationalization resources.

## Usage

Original Structure:

```text
.
└── lib/
    └── l10n/
        ├── en/
        │   ├── global.yaml
        │   └── feature-1.yaml
        └── zh/
            ├── global.yaml
            └── feature-1.yaml
```

Execution:

```shell
dart run arb_glue
# or
flutter pub run arb_glue
```

Resulting structure:

```text
.
└── lib/
    └── l10n/
        ├── en/
        │   ├── global.yaml
        │   └── feature-1.yaml
        ├── zh/
        │   ├── global.yaml
        │   └── feature-1.yaml
        ├── en.arb
        └── zh.arb
```

## Supported formats

Currently, ARB Glue supports JSON and YAML encoded files.

In addition to ARB format, it allows writing descriptions directly into one key:

```json
{
  "myButton": "My Button {type}",
  "@myButton": {
    "description": "My custom button label",
    "placeholders": {
      "type": {"type": "String"}
    }
  }
}
```

This is equivalent to:

```yaml
myButton:
  text: My Button
  description: My custom button label
  placeholders:
    type: {type: String}
```

And equal to:

```yaml
myButton:
- My Button
- My custom button label # description and placeholders can switch lines
- type: {type: String}
```

### Context

Each file can have its own prefix by setting `@@context`:

```yaml
"@@context": "myFeature"
button: "My Feature Button"
```

This will render:

```json
{
  "myFeatureButton": "My Feature Button"
}
```

### Configuration

There are two methods to configure the process:
via pubspec.yaml or through command-line arguments.

pubspec.yaml:

```yaml
# pubspec.yaml
name: MyApp
arb_glue:
  source: lib/l10n
```

Command line:

```shell
dart run arb_glue --source lib/l10n
```

Full configuration options:

```yaml
arb_glue:
  # The source folder contains the files.
  # Type: String
  source: lib/l10n
  # The destination folder where the files will be generated.
  # Type: String
  destination: lib/l10n
  # Blacklisted folders inside the [source].
  # Type: List<String>
  exclude:
  # The author of the arb file.
  # Type: String
  author:
  # The context of the arb file.
  # Type: String
  context:
  # The base locale of the arb file.
  # If not provided, the base locale will be the first locale found in the
  # source folder.
  # Type: String
  base:
  # Whether to print verbose output.
  # Type: bool
  verbose: false
```

[ARB]: https://github.com/google/app-resource-bundle/wiki/ApplicationResourceBundleSpecification
