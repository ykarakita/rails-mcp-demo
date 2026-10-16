# 汎用ツールから Rails 自身の /api/* をアプリ内で呼び出す。
# freee-mcp がパスを OpenAPI スキーマで検証するのと同じく、存在しないルートは実行前に弾く。
module Generic
  module ApiClient
    module_function

    def request(method, path, query: nil, body: nil)
      uri = URI.parse(path)
      unless uri.path.start_with?("/api/") && routable?(method, uri.path)
        return error("#{method.upcase} #{uri.path} は存在しません。api_list_paths で呼べるパスを確認してください")
      end

      uri.query = [ uri.query, query&.to_query ].compact_blank.join("&").presence
      env = { "CONTENT_TYPE" => "application/json", "HTTP_ACCEPT" => "application/json", "HTTP_HOST" => "localhost" }
      env[:input] = body.to_json if body

      response = Rack::MockRequest.new(Rails.application).request(method.to_s.upcase, uri.to_s, env)
      text = [ "HTTP #{response.status}", response.body.presence ].compact.join("\n")
      MCP::Tool::Response.new([ { type: "text", text: text } ], error: response.status >= 400)
    rescue URI::InvalidURIError
      error("パスの形式が不正です: #{path}")
    end

    # "GET /api/todos" のような、呼べるルートの一覧
    def paths
      Rails.application.routes.routes.filter_map do |route|
        path = route.path.spec.to_s.delete_suffix("(.:format)")
        "#{route.verb} #{path}" if path.start_with?("/api/") && route.verb.present?
      end
    end

    def routable?(method, path)
      Rails.application.routes.recognize_path(path, method: method)
      true
    rescue ActionController::RoutingError
      false
    end

    def error(message)
      MCP::Tool::Response.new([ { type: "text", text: message } ], error: true)
    end
  end
end
