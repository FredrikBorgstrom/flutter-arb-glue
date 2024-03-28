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
cancelButton:
  text: "Cancel"
  description: "Cancel the process"
```

### Contents of feature-1.yaml (English)

```yaml
"@@context": "feature1"
title: "Feature 1"
subtitle:
  text: "This feature is enabled at {date}"
  description: Placing below title
  placeholders:
    date:
      type: DateTime
      description: When is the feature enabled
      example: 1995/01/23
```

### Contents of global.yaml (Chinese)

```yaml
okButton: "確定"
cancelButton: "取消"
```

### Contents of feature-1.yaml (Chinese)

```yaml
"@@context": "feature1"
title: "功能 1"
subtitle: "這功能啟動於 {date}"
```

## Using ARB Glue

To merge these files using ARB Glue, follow these steps:

1. Execute ARB Glue:

    dart run arb_glue --source example --destination example --base en

2. Verify Output:
   After executing ARB Glue, the directory structure will be updated as follows:

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

### Output ARB Files

Contents of `en.arb`:

```json
{
  "@@locale": "en",
  "@@last_modified": "2024-03-28T11:50:10.946578Z",
  "okButton": "OK",
  "@okButton": {
    "description": "Finish the process"
  },
  "cancelButton": "Cancel",
  "@cancelButton": {
    "description": "Cancel the process"
  },
  "feature1Title": "Feature 1",
  "feature1Subtitle": "This feature is enabled at {date}",
  "@feature1Subtitle": {
    "description": "Placing below title",
    "placeholders": {
      "date": {
        "type": "DateTime",
        "description": "When is the feature enabled",
        "example": "1995/01/23"
      }
    }
  }
}
```

Contents of `zh.arb`:

```json
{
  "@@locale": "zh",
  "@@last_modified": "2024-03-28T11:50:10.950440Z",
  "okButton": "確定",
  "@okButton": {
    "description": "Finish the process"
  },
  "cancelButton": "取消",
  "@cancelButton": {
    "description": "Cancel the process"
  },
  "feature1Title": "功能 1",
  "feature1Subtitle": "這功能啟動於 {date}",
  "@feature1Subtitle": {
    "description": "Placing below title",
    "placeholders": {
      "date": {
        "type": "DateTime",
        "description": "When is the feature enabled",
        "example": "1995/01/23"
      }
    }
  }
}
```

## Conclusion

ARB Glue simplifies the process of merging multiple language files into ARB format,
making it easier to manage internationalization resources in Flutter projects.
