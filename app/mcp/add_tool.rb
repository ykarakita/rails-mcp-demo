class AddTool < MCP::Tool
  tool_name "add"
  description "2つの数を足し算する"
  input_schema(
    properties: {
      a: { type: "number", description: "1つ目の数" },
      b: { type: "number", description: "2つ目の数" }
    },
    required: [ "a", "b" ]
  )

  def self.call(a:, b:, server_context:)
    MCP::Tool::Response.new([ { type: "text", text: (a + b).to_s } ])
  end
end
