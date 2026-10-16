# MCP の Streamable HTTP エンドポイント。
# リクエストごとに server と transport を作る「Rails コントローラ方式」なので、
# セッションを持たない stateless モード + JSON レスポンスで動かす。
class McpController < ActionController::API
  TOOLS = [ AddTool, ListTodosTool, CreateTodoTool, CompleteTodoTool ].freeze

  def handle
    server = MCP::Server.new(name: "rails_mcp_demo", version: "0.1.0", tools: TOOLS)
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
