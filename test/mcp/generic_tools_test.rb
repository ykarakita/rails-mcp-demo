require "test_helper"

class GenericToolsTest < ActiveSupport::TestCase
  def text_of(response)
    response.content.first[:text]
  end

  test "api_list_paths lists the todo routes" do
    text = text_of(Generic::ApiListPathsTool.call(server_context: nil))

    assert_includes text, "GET /api/todos"
    assert_includes text, "DELETE /api/todos/:id"
  end

  test "api_get passes query parameters" do
    response = Generic::ApiGetTool.call(path: "/api/todos", query: { status: "all" }, server_context: nil)

    assert_not response.error?
    assert_includes text_of(response), "週報を書く"
  end

  test "api_post creates a todo" do
    assert_difference "Todo.count", 1 do
      response = Generic::ApiPostTool.call(path: "/api/todos", body: { title: "掃除する" }, server_context: nil)
      assert_includes text_of(response), "HTTP 201"
    end
  end

  test "api_patch completes a todo" do
    todo = todos(:milk)
    Generic::ApiPatchTool.call(path: "/api/todos/#{todo.id}", body: { completed: true }, server_context: nil)

    assert todo.reload.completed?
  end

  test "api_delete deletes a todo" do
    assert_difference "Todo.count", -1 do
      Generic::ApiDeleteTool.call(path: "/api/todos/#{todos(:milk).id}", server_context: nil)
    end
  end

  test "4xx responses are reported as tool errors" do
    response = Generic::ApiGetTool.call(path: "/api/todos/0", server_context: nil)

    assert response.error?
    assert_includes text_of(response), "HTTP 404"
  end

  test "unknown paths are rejected before running" do
    response = Generic::ApiDeleteTool.call(path: "/api/todos", server_context: nil)

    assert response.error?
    assert_includes text_of(response), "api_list_paths"
  end

  test "paths outside /api are rejected" do
    assert Generic::ApiGetTool.call(path: "/up", server_context: nil).error?
  end
end
