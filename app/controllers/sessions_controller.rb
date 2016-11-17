class SessionsController < Devise::SessionsController
	include ApplicationHelper
	skip_authorization_check
	layout "plain"
end