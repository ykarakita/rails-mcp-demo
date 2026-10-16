---
name: todo-api
description: rails-demo-generic MCP サーバーの汎用ツール (api_get / api_post / api_patch / api_delete) で TODO を操作するときの手順書。TODO の確認・追加・完了・変更・削除を頼まれたら使う。
---

# TODO API の使い方

rails-demo-generic サーバーのツールは、パスとボディを受け取って `/api/*` を呼ぶだけの汎用ツールです。
どのパスに何を送るかはこのスキルに従ってください。エンドポイントの詳細は [references/endpoints.md](references/endpoints.md) にあります。

## よくある操作

| やりたいこと | ツール | パス | ボディ / クエリ |
|---|---|---|---|
| 未完了の一覧 | `api_get` | `/api/todos` | なし |
| すべての一覧 | `api_get` | `/api/todos` | query: `{"status": "all"}` |
| 追加 | `api_post` | `/api/todos` | `{"title": "...", "due_on": "YYYY-MM-DD"}` |
| 完了にする | `api_patch` | `/api/todos/{id}` | `{"completed": true}` |
| 完了を取り消す | `api_patch` | `/api/todos/{id}` | `{"completed": false}` |
| 期限やタイトルの変更 | `api_patch` | `/api/todos/{id}` | 変える項目だけ |
| 削除 | `api_delete` | `/api/todos/{id}` | なし |

## 守ること

- 完了・変更・削除の前に、必ず `api_get /api/todos` で id とタイトルを確認する。候補が複数あればユーザーに確認する。
- 削除は元に戻せない。ユーザーが「消して」と明示したときだけ使い、「終わった」は削除ではなく完了にする。
- 「明日」「来週金曜」などの相対的な期限は、今日の日付から `YYYY-MM-DD` に変換する。
- レスポンスは `HTTP <status>` の行と JSON 本文。4xx はエラーなので、本文の `error` / `errors` を読んで直す。
- ユーザーへの返答では id や JSON を見せず、自然な文章でまとめる。
