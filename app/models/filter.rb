class Filter < ApplicationRecord
  belongs_to :user
  belongs_to :filterable, polymorphic: true

  validates :name, presence: true
  validates :params, presence: true

end