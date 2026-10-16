class ListTodosTool < MCP::Tool
  tool_name "list_todos"
  description "TODO の一覧を返す。status で未完了・完了済み・すべてを切り替えられる"
  input_schema(
    properties: {
      status: {
        type: "string",
        enum: [ "open", "completed", "all" ],
        description: "open=未完了 (デフォルト), completed=完了済み, all=すべて"
      }
    }
  )
  annotations(read_only_hint: true, destructive_hint: false, open_world_hint: false)

  def self.call(server_context:, status: "open")
    todos = case status
    when "completed" then Todo.completed
    when "all" then Todo.all
    else Todo.incomplete
    end
    todos = todos.order(Arel.sql("due_on IS NULL"), :due_on, :id)

    text = todos.map(&:to_line).join("\n").presence || "該当する TODO はありません"
    MCP::Tool::Response.new([ { type: "text", text: text } ])
  end
end
