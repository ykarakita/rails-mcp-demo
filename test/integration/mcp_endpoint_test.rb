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
end
