class ContactList
  include Mongoid::Document
  include Mongoid::Timestamps # adds created_at and updated_at fields

  has_and_belongs_to_many :users , inverse_of: nil
  embedded_in :user

  def nicknames
    users.map(&:nickname)
  end

  ## add new contact in current and new user
  #
  def add_contact(user_to_add)
    self << user_to_add
    user_to_add.contact_list << user
  end

  ## delete contact in current and old user
  #
  def remove_contact(user_to_delete)
    users.delete(user_to_delete)
    user_to_delete.contact_list.users.delete(user)
  end

  def <<(user_to_add)
      users << user_to_add
  end
end
