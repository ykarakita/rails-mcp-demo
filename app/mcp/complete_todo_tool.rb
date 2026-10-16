class CompleteTodoTool < MCP::Tool
  tool_name "complete_todo"
  description "TODO を完了にする。id は list_todos で確認できる"
  input_schema(
    properties: {
      id: { type: "integer", description: "TODO の id" }
    },
    required: [ "id" ]
  )
  annotations(read_only_hint: false, destructive_hint: false, idempotent_hint: true, open_world_hint: false)

  def self.call(id:, server_context:)
    todo = Todo.find_by(id: id)
    unless todo
      return MCP::Tool::Response.new([ { type: "text", text: "id=#{id} の TODO が見つかりません" } ], error: true)
    end

    todo.complete!
    MCP::Tool::Response.new([ { type: "text", text: "完了にしました: #{todo.to_line}" } ])
  end
end
