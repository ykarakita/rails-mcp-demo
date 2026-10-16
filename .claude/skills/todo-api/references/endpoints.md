# TODO API エンドポイント

## Todo の JSON

```json
{
  "id": 3,
  "title": "病院を予約する",
  "notes": null,
  "due_on": "2026-10-19",
  "completed_at": null,
  "created_at": "2026-10-16T13:45:00.000Z",
  "updated_at": "2026-10-16T13:45:00.000Z"
}
```

`completed_at` が null なら未完了。

## GET /api/todos

一覧を期限が近い順 (期限なしは最後) に返す。

| クエリ | 値 | 既定 |
|---|---|---|
| `status` | `open` (未完了) / `completed` (完了済み) / `all` | `open` |

- 200: Todo の配列

## GET /api/todos/{id}

- 200: Todo
- 404: `{"error": "TODO が見つかりません"}`

## POST /api/todos

| 項目 | 型 | 必須 |
|---|---|---|
| `title` | string | ✅ |
| `notes` | string | |
| `due_on` | string (YYYY-MM-DD) | |
| `completed` | boolean | |

- 201: 作成した Todo
- 422: `{"errors": ["Title can't be blank"]}`

## PATCH /api/todos/{id}

POST と同じ項目を、変えるものだけ送る。`completed: true` で完了、`false` で未完了に戻す。

- 200: 更新後の Todo
- 404 / 422: POST と同じ

## DELETE /api/todos/{id}

- 204: 本文なし
- 404: `{"error": "TODO が見つかりません"}`
