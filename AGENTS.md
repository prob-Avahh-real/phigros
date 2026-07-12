# AGENTS.md — phigros

Phigros-style rhythm game replica - dynamic judgment line mobile rhythm game

## 命令
```bash
make test          # flutter test
make analyze       # flutter analyze
make format        # dart format .
make build-android # flutter build apk --release
make run           # flutter run
```

## 技术栈
Flutter / Dart 3.12+

## 约定
- Lint: flutter_lints + 自定义规则
- 测试文件在 `test/` 目录
- Service 层返回 Result<T>
