module Generic
  class ApiPostTool < MCP::Tool
    tool_name "api_post"
    description "API に POST リクエストを送り、データを新しく作成する"
    input_schema(
      properties: {
        path: { type: "string", description: "API のパス。例: /api/todos" },
        body: { type: "object", description: "JSON のリクエストボディ" }
      },
      required: [ "path", "body" ]
    )
    annotations(read_only_hint: false, destructive_hint: false, idempotent_hint: false, open_world_hint: false)

    def self.call(path:, body:, server_context:)
      ApiClient.request(:post, path, body: body)
    end
  end
end
