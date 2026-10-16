module Generic
  class ApiDeleteTool < MCP::Tool
    tool_name "api_delete"
    description "API に DELETE リクエストを送り、データを削除する。元に戻せない"
    input_schema(
      properties: {
        path: { type: "string", description: "API のパス。例: /api/todos/3" }
      },
      required: [ "path" ]
    )
    annotations(read_only_hint: false, destructive_hint: true, idempotent_hint: true, open_world_hint: false)

    def self.call(path:, server_context:)
      ApiClient.request(:delete, path)
    end
  end
end
