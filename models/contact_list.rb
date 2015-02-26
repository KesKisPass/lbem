class ContactList
  include Mongoid::Document
#  include Mongoid::Timestamps::Create # adds created_at and updated_at fields

  has_and_belongs_to_many :users , inverse_of: nil
  embedded_in :user

  def nicknames
    users.map(&:nickname)
  end

  def <<(user_to_add)
      users << user_to_add
  end

  ## invite contact
  #
  # @param user_to_invite [User] user to invite by current user
  def invite_contact(user_to_invite)
    user.pending_contacts.create!( requestee: user_to_invite ) if user.pending_contacts.where(requestee_id: user_to_invite._id).length.zero? and users.where(_id: user_to_invite._id).length.zero? and !user._id.eql?(user_to_invite._id)
  end

  ## delete contact in current and old user
  #
  # @param user_to_delete [User] user to remove in current user contact list
  def remove_contact(user_to_remove)
    users.delete(user_to_remove)
    user_to_remove.contact_list.users.delete(user)
  end

  ## accept invitation
  #
  # @param user_to_accept [User] requester to accept
  def accept_invitation(user_to_accept)
    add_contact(user_to_accept) unless PendingContact.where(requester_id: user_to_accept._id, requestee_id: user._id).delete.zero? 
  end

  ## cancel invitation
  #
  # @param user_to_cancel [User] requester invitation to cancel by current user
  def cancel_invitation(user_to_cancel)
    PendingContact.or({requester_id: user_to_cancel._id, requestee_id: user._id}, {requester_id: user._id, requestee_id: user_to_cancel._id}).delete
  end

private

  ## add new contact in current and new user
  #
  # @param user_to_add [User] user to add in current user contact list
  def add_contact(user_to_add)
    self << user_to_add
    user_to_add.contact_list << user
  end

end
