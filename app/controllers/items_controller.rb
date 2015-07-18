class ItemsController < ApplicationController
  before_filter :sign_in_buyer

  def new
  end

  def create
    if create_order?
      @product = Product.find_by_id(params[:id])
      if @product.flag == 'n' #中途被人提前借走
          flash[:warning] = "你来晚了,图书已借出!"
          redirect_to @product
      end
      @item = Item.new(product_id:params[:id], order_id:current_order.id, product_name:@product.title, product_price:@product.price, commentable:true)
      if exisited_item(@item.product_id) or @item.save
        Product.update(@product.id, :flag => 'n') #更新flag表示已经借出
        #current_order.count += 1 #count用来判断是否order里面的全部记录都已经评论完
        #Order.update(current_order.id, :count => current_order.count)
        redirect_to current_order
      else
        render new_item_path
      end
    end
  end

  def destroy
      product_id = current_order.items.find_by_id(params[:id]).product_id
      Product.update(product_id, :flag => 'y')
      current_order.items.find_by_id(params[:id]).destroy
    
      respond_to do |format|
          format.html {redirect_to current_order}
          format.js
      end
  end

  def show
    current_buyer.orders.each do |order|
        @item = order.items.find_by_id(params[:id])
        if !@item.nil?
            break
        end
    end
    if !@item.nil?
      @product = Product.find_by_id(@item.product_id)
      if !@product.nil?
        @comment = Comment.new(product_id:@product.id, buyer_id:current_buyer.id, item_id:params[:id])
      else
        flash[:warning] = "This song maybe has been deleted!"
        redirect_to current_buyer
      end
    else
      flash[:warning] = "The music item #{params[:id]} is not existed or doesn't belong to you!"
      redirect_to current_buyer
    end
  end

  def index
    redirect_to current_buyer
  end
end
