require "test_helper"

class McpEndpointTest < ActionDispatch::IntegrationTest
  HEADERS = {
    "Content-Type" => "application/json",
    "Accept" => "application/json, text/event-stream"
  }.freeze

  # MCP SDK の DNS リバインディング対策で、loopback 以外の Host は 403 になる
  setup { host! "localhost" }

  def rpc(method, params = nil, id: 1)
    body = { jsonrpc: "2.0", id: id, method: method }
    body[:params] = params if params
    headers = HEADERS
    headers = headers.merge("MCP-Protocol-Version" => "2025-06-18") unless method == "initialize"

    post "/mcp", params: body.to_json, headers: headers
    assert_response :success
    response.parsed_body.fetch("result")
  end

  test "initialize returns server info and instructions" do
    result = rpc("initialize", {
      protocolVersion: "2025-06-18",
      capabilities: {},
      clientInfo: { name: "test", version: "0" }
    })

    assert_equal "rails_mcp_demo", result.dig("serverInfo", "name")
    assert_includes result["instructions"], "list_todos"
  end

  test "tools/list lists the todo tools" do
    names = rpc("tools/list")["tools"].map { |tool| tool["name"] }

    assert_equal %w[add list_todos create_todo complete_todo], names
  end

  test "tools/call runs a tool" do
    result = rpc("tools/call", { name: "list_todos", arguments: { status: "all" } })

    assert_equal false, result["isError"]
    assert_includes result.dig("content", 0, "text"), "牛乳を買う"
  end

  test "resources/list and resources/templates/list advertise the todo resources" do
    assert_equal [ "todos://incomplete" ], rpc("resources/list")["resources"].map { |r| r["uri"] }
    assert_equal [ "todo://{id}" ], rpc("resources/templates/list")["resourceTemplates"].map { |t| t["uriTemplate"] }
  end

  test "resources/read returns incomplete todos as markdown" do
    contents = rpc("resources/read", { uri: "todos://incomplete" })["contents"].first

    assert_equal "text/markdown", contents["mimeType"]
    assert_includes contents["text"], "牛乳を買う"
    assert_not_includes contents["text"], "週報を書く"
  end

  test "resources/read expands the todo template" do
    todo = todos(:report)
    contents = rpc("resources/read", { uri: "todo://#{todo.id}" })["contents"].first

    assert_equal "週報を書く", JSON.parse(contents["text"])["title"]
  end

  test "resources/read reports an unknown todo as not found" do
    post "/mcp", params: { jsonrpc: "2.0", id: 1, method: "resources/read", params: { uri: "todo://0" } }.to_json,
                 headers: HEADERS.merge("MCP-Protocol-Version" => "2025-06-18")

    assert_equal -32602, response.parsed_body.dig("error", "code")
  end
end
