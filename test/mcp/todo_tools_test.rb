require "test_helper"

class TodoToolsTest < ActiveSupport::TestCase
  def text_of(response)
    response.content.first[:text]
  end

  test "list_todos returns incomplete todos by default" do
    text = text_of(ListTodosTool.call(server_context: nil))

    assert_includes text, "牛乳を買う"
    assert_not_includes text, "週報を書く"
  end

  test "list_todos with status all includes completed todos" do
    text = text_of(ListTodosTool.call(status: "all", server_context: nil))

    assert_includes text, "[x] 週報を書く"
  end

  test "create_todo adds a todo" do
    assert_difference "Todo.count", 1 do
      response = CreateTodoTool.call(title: "掃除する", due_on: "2026-10-31", server_context: nil)
      assert_not response.error?
    end
    assert_equal Date.new(2026, 10, 31), Todo.last.due_on
  end

  test "create_todo reports an invalid date as an error" do
    response = CreateTodoTool.call(title: "掃除する", due_on: "来週", server_context: nil)

    assert response.error?
    assert_includes text_of(response), "YYYY-MM-DD"
  end

  test "complete_todo marks a todo completed" do
    todo = todos(:milk)
    response = CompleteTodoTool.call(id: todo.id, server_context: nil)

    assert_not response.error?
    assert todo.reload.completed?
  end

  test "complete_todo reports a missing id as an error" do
    assert CompleteTodoTool.call(id: 0, server_context: nil).error?
  end
end
