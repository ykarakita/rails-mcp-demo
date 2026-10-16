module Generic
  class ApiListPathsTool < MCP::Tool
    tool_name "api_list_paths"
    description "呼び出せる API のメソッドとパスの一覧を返す"
    input_schema(properties: {})
    annotations(read_only_hint: true, destructive_hint: false, idempotent_hint: true, open_world_hint: false)

    def self.call(server_context:)
      MCP::Tool::Response.new([ { type: "text", text: ApiClient.paths.join("\n") } ])
    end
  end
end
