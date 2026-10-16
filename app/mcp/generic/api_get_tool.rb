module Generic
  class ApiGetTool < MCP::Tool
    tool_name "api_get"
    description "API に GET リクエストを送り、データを取得する"
    input_schema(
      properties: {
        path: { type: "string", description: "API のパス。例: /api/todos, /api/todos/3" },
        query: { type: "object", description: "クエリパラメータ (任意)。例: {\"status\": \"all\"}" }
      },
      required: [ "path" ]
    )
    annotations(read_only_hint: true, destructive_hint: false, idempotent_hint: true, open_world_hint: false)

    def self.call(path:, server_context:, query: nil)
      ApiClient.request(:get, path, query: query)
    end
  end
end
