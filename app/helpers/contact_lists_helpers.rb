module Lbem
  class App
    module ContactListsHelper

      def ensure_himself!(target_user)
        error 403, 'Forbidden' unless current_user.nickname == target_user
      end

    end

    helpers ContactListsHelper
  end
end
