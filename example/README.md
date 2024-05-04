# Using ARB Glue

In this example, we'll demonstrate how to use ARB Glue to merge multiple language files into a single ARB format file.

## Input Files

Suppose we have the following directory structure containing language files:

```text
.
└── example/
    ├── en/
    │   ├── global.yaml
    │   └── feature-1.yaml
    └── zh/
        ├── global.yaml
        └── feature-1.yaml
```

### Contents of global.yaml (English)

```yaml
okButton:
  text: "OK"
  description: "Finish the process"
...
```

### Contents of feature-1.yaml (English)

```yaml
$prefix: feature1
title: "Feature 1"
...
```

### Contents of global.yaml (Chinese)

```yaml
okButton: "確定"
...
```

### Contents of feature-1.yaml (Chinese)

```yaml
$prefix: "feature1"
title: "功能 1"
...
```

## Using ARB Glue

To merge these files using ARB Glue, follow these steps:

1. Execute ARB Glue:

    dart run arb_glue --source example --destination example --base en

2. Verify Output:
   After executing ARB Glue, the directory structure will be updated as follows:

   ```text
    .
    └── example/
        ├── en/
        │   ├── global.yaml
        │   └── feature-1.yaml
        ├── zh/
        │   ├── global.yaml
        │   └── feature-1.yaml
        ├── en.arb
        └── zh.arb
    ```

### Output ARB Files

Contents of `en.arb`:

```json
{
  "@@locale": "en",
  "okButton": "OK",
  "@okButton": {
    "description": "Finish the process"
  },
  "feature1Title": "Feature 1",
  "...": "..."
}
```

Contents of `zh.arb`:

```json
{
  "@@locale": "zh",
  "okButton": "確定",
  "@okButton": {
    "description": "Finish the process"
  },
  "feature1Title": "功能 1",
  "...": "..."
}
```

## Conclusion

ARB Glue simplifies the process of merging multiple language files into ARB format,
making it easier to manage internationalization resources in Flutter projects.
