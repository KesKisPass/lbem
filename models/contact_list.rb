class ContactList

  class ContactListError < StandardError; end
  class ContactListInvitationError < ContactListError; end

  class AlreadyAContactError < ContactListInvitationError; end
  class AlreadyARequesterError < ContactListInvitationError; end
  class AlreadyARequesteeError < ContactListInvitationError; end

  include Mongoid::Document
  include Mongoid::Timestamps::Created # adds created_at and updated_at fields

  has_and_belongs_to_many :contacts , inverse_of: nil, class_name: 'User'
  embedded_in :user

  def <<(user_to_add)
    contacts << user_to_add
  end

  def as_json(options = {})
    super({except: [:_id, :created_at, :contact_ids], include: { contacts: {only: [:nickname]} }})
  end

  ## invite contact
  #
  # @param user_to_invite [User] user to invite by current user
  # @raise [ArgumentError] if user_to_invite is already in pending, or in contacts
  # @return [TrueClass] if invited. Nil otherwhise
  def invite_contact(user_to_invite)
    return if user._id == user_to_invite._id
    raise AlreadyAContactError, 'Already a contact' if contacts.where(_id: user_to_invite._id).exists?
    raise AlreadyARequesteeError, 'You already asked this user' if user.pending_contacts.where(requestee_id: user_to_invite._id).exists?
    raise AlreadyARequesterError, 'This user already asked you' if user.pending_contacts.where(requester_id: user_to_invite._id).exists?
    user.pending_contacts.create!( requestee: user_to_invite )
    true
  end

  ## delete contact in current and old user
  #
  # @param user_to_delete [User] user to remove in current user contact list
  # @raise [ArgumentError] if user_to_remove is not in contact_list
  # @return [TrueClass] if deleted
  def remove_contact(user_to_remove)
    raise ArgumentError, 'Not a contact' unless contacts.where(_id: user_to_remove._id).exists?
    contacts.delete(user_to_remove)
    user_to_remove.contact_list.contacts.delete(user)
    true
  end

  ## accept invitation
  #
  # @param user_to_accept [User] requester to accept
  # @raise [ArgumentError] if not requested
  # return [TrueClass] if accepted
  def accept_invitation(user_to_accept)
    raise ArgumentError, 'Contact request not found' if PendingContact.where(requester_id: user_to_accept._id, requestee_id: user._id).delete.zero? 
    add_contact(user_to_accept)
    true
  end

  ## cancel invitation
  #
  # @param user_to_cancel [User] requester invitation to cancel by current user
  # @raise [ArgumentError] if not requested
  # @return [TrueClass] if canceled
  def cancel_invitation(user_to_cancel)
    raise ArgumentError, 'Contact request not found' if PendingContact.or({requester_id: user_to_cancel._id, requestee_id: user._id}, {requester_id: user._id, requestee_id: user_to_cancel._id}).delete.zero?
    true
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
