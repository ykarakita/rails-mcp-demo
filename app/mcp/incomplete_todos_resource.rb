# 未完了 TODO の一覧。固定の URI を持つリソース。
class IncompleteTodosResource < MCP::Resource
  uri "todos://incomplete"
  resource_name "incomplete_todos"
  title "未完了の TODO"
  description "未完了の TODO を期限順に並べた Markdown"
  mime_type "text/markdown"

  def self.contents
    todos = Todo.incomplete.order(Arel.sql("due_on IS NULL"), :due_on, :id)
    lines = todos.map { |todo| "- #{todo.title}#{" (期限: #{todo.due_on.iso8601})" if todo.due_on}" }
    text = [ "# 未完了の TODO (#{todos.size}件)", "", *lines ].join("\n")

    MCP::Resource::TextContents.new(uri: uri, mime_type: mime_type, text: text)
  end
end
