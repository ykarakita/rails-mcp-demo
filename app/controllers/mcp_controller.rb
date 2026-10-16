# MCP の Streamable HTTP エンドポイント。
# リクエストごとに server と transport を作る「Rails コントローラ方式」なので、
# セッションを持たない stateless モード + JSON レスポンスで動かす。
class McpController < ActionController::API
  TOOLS = [ AddTool, ListTodosTool, CreateTodoTool, CompleteTodoTool ].freeze
  RESOURCES = [ IncompleteTodosResource ].freeze
  RESOURCE_TEMPLATES = [ TodoResourceTemplate ].freeze

  # 接続時に Claude へ渡される、サーバー全体の使い方の説明
  INSTRUCTIONS = <<~TEXT.freeze
    ユーザーの TODO リストを管理するサーバーです。
    - TODO を完了にする前に list_todos で一覧を取得し、id とタイトルが合っているか確認してください。タイトルが曖昧で複数の候補がある場合は、どれのことかユーザーに確認してください。
    - 「明日」「来週金曜」のような相対的な期限は、今日の日付から YYYY-MM-DD に変換して create_todo の due_on に渡してください。
    - ツールの結果は「#id [ ] タイトル (期限: YYYY-MM-DD)」の形式です。[x] は完了済みを表します。ユーザーに見せるときは id を省き、自然な文章でまとめてください。
  TEXT

  def handle
    server = MCP::Server.new(
      name: "rails_mcp_demo",
      version: "0.1.0",
      instructions: INSTRUCTIONS,
      tools: TOOLS,
      resources: RESOURCES,
      resource_templates: RESOURCE_TEMPLATES
    )
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
