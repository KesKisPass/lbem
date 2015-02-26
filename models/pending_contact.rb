# -*- coding: utf-8 -*-
class PendingContact
  include Mongoid::Document
#  include Mongoid::Timestamps::Create # adds created_at and updated_at fields

  belongs_to :requester, class_name: "User"
  belongs_to :requestee, class_name: "User"

end
