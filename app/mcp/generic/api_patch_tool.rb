module Generic
  class ApiPatchTool < MCP::Tool
    tool_name "api_patch"
    description "API に PATCH リクエストを送り、データの一部を更新する"
    input_schema(
      properties: {
        path: { type: "string", description: "API のパス。例: /api/todos/3" },
        body: { type: "object", description: "変更する項目だけを入れた JSON のリクエストボディ" }
      },
      required: [ "path", "body" ]
    )
    annotations(read_only_hint: false, destructive_hint: false, idempotent_hint: true, open_world_hint: false)

    def self.call(path:, body:, server_context:)
      ApiClient.request(:patch, path, body: body)
    end
  end
end
