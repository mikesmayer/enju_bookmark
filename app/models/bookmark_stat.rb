class BookmarkStat < ActiveRecord::Base
  include CalculateStat
  default_scope :order => 'id DESC'
  scope :not_calculated, where(:state => 'pending')
  has_many :bookmark_stat_has_manifestations
  has_many :manifestations, :through => :bookmark_stat_has_manifestations

  state_machine :initial => :pending do
    before_transition :pending => :completed, :do => :calculate_count
    event :calculate do
      transition :pending => :completed
    end
  end

  def self.per_page
    10
  end

  def calculate_count
    self.started_at = Time.zone.now
    Manifestation.find_each do |manifestation|
      daily_count = Bookmark.manifestations_count(self.start_date, self.end_date, manifestation)
      #manifestation.update_attributes({:daily_bookmarks_count => daily_count, :total_count => manifestation.total_count + daily_count})
      if daily_count > 0
        self.manifestations << manifestation
        sql = ['UPDATE bookmark_stat_has_manifestations SET bookmarks_count = ? WHERE bookmark_stat_id = ? AND manifestation_id = ?', daily_count, self.id, manifestation.id]
        ActiveRecord::Base.connection.execute(
          self.class.send(:sanitize_sql_array, sql)
        )
      end
    end
    self.completed_at = Time.zone.now
  end
end

# == Schema Information
#
# Table name: bookmark_stats
#
#  id           :integer         not null, primary key
#  start_date   :datetime
#  end_date     :datetime
#  note         :text
#  state        :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#  started_at   :datetime
#  completed_at :datetime
#
