class Todo < ApplicationRecord
  validates :title, presence: true

  scope :incomplete, -> { where(completed_at: nil) }
  scope :completed, -> { where.not(completed_at: nil) }
  scope :by_status, ->(status) {
    case status
    when "completed" then completed
    when "all" then all
    else incomplete
    end
  }
  # 期限が近い順。期限なしは最後
  scope :by_due, -> { order(Arel.sql("due_on IS NULL"), :due_on, :id) }

  def completed?
    completed_at.present?
  end

  def complete!
    update!(completed_at: Time.current) unless completed?
  end

  # Claude に渡す1行表示。例: "#3 [ ] 牛乳を買う (期限: 2026-10-20)"
  def to_line
    line = "##{id} [#{completed? ? "x" : " "}] #{title}"
    line += " (期限: #{due_on.iso8601})" if due_on
    line += "\n    メモ: #{notes}" if notes.present?
    line
  end
end
