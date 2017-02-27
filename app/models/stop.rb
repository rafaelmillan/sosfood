class Stop < ApplicationRecord
  belongs_to :station
  belongs_to :line
end
