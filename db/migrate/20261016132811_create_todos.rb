class CreateTodos < ActiveRecord::Migration[8.1]
  def change
    create_table :todos do |t|
      t.string :title, null: false
      t.text :notes
      t.date :due_on
      t.datetime :completed_at

      t.timestamps
    end
  end
end
