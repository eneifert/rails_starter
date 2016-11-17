class PasswordsController < Devise::PasswordsController
	include ApplicationHelper
	skip_authorization_check
	layout "plain"
end