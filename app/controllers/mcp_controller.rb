# MCP の Streamable HTTP エンドポイント。
# リクエストごとに server と transport を作る「Rails コントローラ方式」なので、
# セッションを持たない stateless モード + JSON レスポンスで動かす。
#
# ルートの variant で2種類のサーバーを出し分ける。
# - default: 用途ごとの専用ツール (list_todos など)
# - generic: API を叩く汎用ツール (api_get など)。使い方は todo-api スキルに書く
class McpController < ActionController::API
  SERVERS = {
    "default" => {
      name: "rails_mcp_demo",
      tools: [ AddTool, ListTodosTool, CreateTodoTool, CompleteTodoTool ],
      resources: [ IncompleteTodosResource ],
      resource_templates: [ TodoResourceTemplate ],
      # 接続時に Claude へ渡される、サーバー全体の使い方の説明
      instructions: <<~TEXT
        ユーザーの TODO リストを管理するサーバーです。
        - TODO を完了にする前に list_todos で一覧を取得し、id とタイトルが合っているか確認してください。タイトルが曖昧で複数の候補がある場合は、どれのことかユーザーに確認してください。
        - 「明日」「来週金曜」のような相対的な期限は、今日の日付から YYYY-MM-DD に変換して create_todo の due_on に渡してください。
        - ツールの結果は「#id [ ] タイトル (期限: YYYY-MM-DD)」の形式です。[x] は完了済みを表します。ユーザーに見せるときは id を省き、自然な文章でまとめてください。
      TEXT
    },
    "generic" => {
      name: "rails_mcp_demo_generic",
      tools: [
        Generic::ApiListPathsTool,
        Generic::ApiGetTool,
        Generic::ApiPostTool,
        Generic::ApiPatchTool,
        Generic::ApiDeleteTool
      ],
      instructions: <<~TEXT
        TODO アプリの JSON API を呼び出す汎用ツールのサーバーです。
        エンドポイントやリクエストボディの詳細、よくある操作の手順は todo-api スキルを参照してください。
        スキルがない場合は api_list_paths で呼べるパスを確認してから操作してください。
      TEXT
    }
  }.freeze

  def handle
    config = SERVERS.fetch(request.path_parameters[:variant])
    server = MCP::Server.new(version: "0.1.0", **config)
    transport = MCP::Server::Transports::StreamableHTTPTransport.new(
      server,
      stateless: true,
      enable_json_response: true,
      serve_subscriptions_listen: false
    )

    status, headers, body = transport.handle_request(request)
    self.status = status
    response.headers.merge!(headers)
    self.response_body = body
  end
end
