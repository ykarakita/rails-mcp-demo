require "test_helper"

class Api::TodosControllerTest < ActionDispatch::IntegrationTest
  test "index returns incomplete todos by default" do
    get "/api/todos", as: :json

    assert_response :success
    assert_equal [ "牛乳を買う" ], response.parsed_body.map { |todo| todo["title"] }
  end

  test "create adds a todo" do
    assert_difference "Todo.count", 1 do
      post "/api/todos", params: { title: "掃除する", due_on: "2026-10-31" }, as: :json
    end

    assert_response :created
    assert_equal "2026-10-31", response.parsed_body["due_on"]
  end

  test "create rejects a blank title" do
    post "/api/todos", params: { title: "" }, as: :json

    assert_response :unprocessable_content
  end

  test "update with completed toggles completed_at" do
    todo = todos(:milk)

    patch "/api/todos/#{todo.id}", params: { completed: true }, as: :json
    assert todo.reload.completed?

    patch "/api/todos/#{todo.id}", params: { completed: false }, as: :json
    assert_not todo.reload.completed?
  end

  test "destroy deletes a todo" do
    assert_difference "Todo.count", -1 do
      delete "/api/todos/#{todos(:milk).id}", as: :json
    end

    assert_response :no_content
  end

  test "show returns 404 for an unknown id" do
    get "/api/todos/0", as: :json

    assert_response :not_found
  end
end
