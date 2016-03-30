class ProductOrdersController < ApplicationController
  before_action :get_order

  def create
    product_order = @order.product_orders.find_or_initialize_by(product_id: product_order_params[:product_id]) do |po|
      po.amount = 0
    end
    product_order.amount += product_order_params[:amount].to_i

    respond_to do |format|
      if product_order.save
        format.html { redirect_to @order, notice: t('added_to_cart', name: product_order.product.name, number: product_order.amount) }
        format.any(:js, :json) do
          @order.reload
          render json: {
            status: :ok,
            items: view_context.pluralize(@order.product_orders.sum(:amount), 'Item'),
            html: {
              menu: render_to_string(partial: 'shared/cart', locals: { cart: @order }, layout: false)
            }
          }
        end
      else
        format.html { redirect_to @order }
        format.any(:js, :json) { render json: { status: :fail, errors: product_order.errors } }
      end
    end
  end

  def destroy
    @product_order = @order.product_orders.find(params[:id])
    product_name = @product_order.product.name
    @product_order.destroy
    respond_to do |format|
      format.html { redirect_to @order, notice: t('removed_from_cart', name: product_name) }
      format.any(:js, :json) do
        render json: {
          status: :ok,
          items: view_context.pluralize(@order.product_orders.sum(:amount), 'Item'),
          html: {
            menu: render_to_string(partial: 'shared/cart', locals: { cart: @order }, layout: false)
          }
        }
      end
    end
  end

  private
  def product_order_params
    params.require(:product_order).permit(:amount, :product_id)
  end

  def get_order
    @order = Order.find(params[:order_id])
  end
end
