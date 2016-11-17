class TestsController < ApplicationController
		
  	before_filter :load_permissions # call this after load_and_authorize else it gives a cancan error
  	before_action :require_user
  	respond_to :html, :json
	skip_authorization_check
	
	def index

		# orders = Order.where("status = 'Completed' and location_id = 6")		

		debug
	
	end

	# def super_secret_route_that_clears_outs_the_stuff_yo
	# 	if Date.today < "3/25/2016".to_date
	# 		Client.delete_all
	# 		# Order.delete_all
	# 		# OrderProduct.delete_all
	# 		# OrderProductReservation.delete_all
	# 		# FeedMillJob.delete_all
	# 		# FeedMillJobItem.delete_all
	# 		# Notification.delete_all
	# 		# Inventory.delete_all
	# 		# ExtrudedInventory.delete_all
	# 		# FeedMillUsageLog.delete_all
	# 		# LostInventory.delete_all
	# 		# InventoryAdjustment.delete_all
	# 		# InventoryChange.delete_all
	# 		# InventoryHistoryTotal.delete_all
	# 		# MovedInventory.delete_all
	# 		# OrderCreditPayment.delete_all
	# 		# OrderCreditPaymentItem.delete_all
	# 		# OrderProductFeedMillJob.delete_all
	# 		# PurchaseOrder.delete_all
	# 		# PurchasePayment.delete_all

	# 		# render :text => "All the data was cleared yo".html_safe
	# 	else
	# 		render :text => "Nope I'm not doing it.".html_safe
	# 	end

	# 	render :text => "Nope I'm not doing it.".html_safe
	# end

	def dev_notes		
		@dev_notes = DeveloperMessage.all.order(sort_column + " " + sort_direction).page params[:page]
	end

	def dbtest
		res = Sequel.ado(:conn_string=>'Provider=Microsoft.ACE.OLEDB.12.0;Data Source=/MixitDat.accdb')
		render plain: res["Select * from [Ingredient Table]"].count
	end

	def clear_all_orders_and_jobs
		return if !Rails.env.development?
		
		Order.delete_all
		OrderProduct.delete_all
		OrderProductReservation.delete_all
		FeedMillJob.delete_all
		FeedMillJobItem.delete_all
		Notification.delete_all
	end
end