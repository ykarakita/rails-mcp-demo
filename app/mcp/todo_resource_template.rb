# TODO 1件の詳細。URI に id を埋め込むリソーステンプレート (例: todo://3)。
class TodoResourceTemplate < MCP::ResourceTemplate
  uri_template "todo://{id}"
  resource_template_name "todo"
  title "TODO の詳細"
  description "TODO 1件の全項目を JSON で返す"
  mime_type "application/json"

  def self.contents(id:)
    uri = "todo://#{id}"
    todo = Todo.find_by(id: id)
    raise MCP::Server::ResourceNotFoundError.new(uri) unless todo

    json = todo.slice(:id, :title, :notes, :due_on, :completed_at, :created_at, :updated_at).to_json
    MCP::Resource::TextContents.new(uri: uri, mime_type: mime_type, text: json)
  end
end
