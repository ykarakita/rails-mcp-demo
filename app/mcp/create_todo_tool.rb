class CreateTodoTool < MCP::Tool
  tool_name "create_todo"
  description "TODO を新しく追加する"
  input_schema(
    properties: {
      title: { type: "string", description: "やること" },
      notes: { type: "string", description: "補足メモ (任意)" },
      due_on: { type: "string", format: "date", description: "期限 YYYY-MM-DD (任意)" }
    },
    required: [ "title" ]
  )
  annotations(read_only_hint: false, destructive_hint: false, open_world_hint: false)

  def self.call(title:, server_context:, notes: nil, due_on: nil)
    todo = Todo.new(title: title, notes: notes, due_on: due_on && Date.iso8601(due_on))

    if todo.save
      MCP::Tool::Response.new([ { type: "text", text: "追加しました: #{todo.to_line}" } ])
    else
      MCP::Tool::Response.new([ { type: "text", text: todo.errors.full_messages.join(", ") } ], error: true)
    end
  rescue Date::Error
    MCP::Tool::Response.new([ { type: "text", text: "due_on は YYYY-MM-DD 形式で指定してください: #{due_on}" } ], error: true)
  end
end
