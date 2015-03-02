class PendingContact

  include Mongoid::Document
  include Mongoid::Timestamps::Created

  belongs_to :requester, class_name: "User"
  belongs_to :requestee, class_name: "User"

  index :requester => 1
  index :requestee => 1

end
