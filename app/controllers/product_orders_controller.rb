class ProductOrdersController < ApplicationController
  before_action :get_order

  def create
    (product_order_params[:amount].try(:to_i) || 0).times do
       @order.product_orders.create(product_id: product_order_params[:product_id])
    end
  end

  def destroy
    @product_order = @order.product_orders.find(params[:id])
  end

  private
  def product_order_params
    params.require(:product_order).permit(:amount, :product_id)
  end

  def get_order
    @order = Order.find(params[:order_id])
  end
end
