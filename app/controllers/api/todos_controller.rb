# TODO の JSON API。汎用 MCP ツール (api_get など) から呼ばれる。
module Api
  class TodosController < ActionController::API
    before_action :set_todo, only: %i[show update destroy]

    rescue_from ActiveRecord::RecordNotFound do
      render json: { error: "TODO が見つかりません" }, status: :not_found
    end

    def index
      render json: Todo.by_status(params[:status]).by_due
    end

    def show
      render json: @todo
    end

    def create
      todo = Todo.new(todo_attributes)

      if todo.save
        render json: todo, status: :created
      else
        render json: { errors: todo.errors.full_messages }, status: :unprocessable_content
      end
    end

    def update
      if @todo.update(todo_attributes)
        render json: @todo
      else
        render json: { errors: @todo.errors.full_messages }, status: :unprocessable_content
      end
    end

    def destroy
      @todo.destroy!
      head :no_content
    end

    private

    def set_todo
      @todo = Todo.find(params[:id])
    end

    # body は {"title": ..., "completed": true} のようにトップレベルで受け取る
    def todo_attributes
      attrs = params.permit(:title, :notes, :due_on, :completed).to_h
      if attrs.key?(:completed)
        completed = ActiveModel::Type::Boolean.new.cast(attrs.delete(:completed))
        attrs[:completed_at] = completed ? (@todo&.completed_at || Time.current) : nil
      end
      attrs
    end
  end
end
