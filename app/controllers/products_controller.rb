class ProductsController < ApplicationController
  def new
    @product = Product.new(buyer_id: current_buyer.id)
  end

  def create
    @new_product = current_buyer.products.create(params[:product])
    @new_product.avatar = params[:product][:avatar] #刚开始没加这句出问题
    @new_product.flag = 'y' #y表示可以借阅
    @new_product.price = 0
    if @new_product.save
      redirect_to '/mybooks'
    else
      render new_product_path
    end
  end

  def index
    @toptens = Comment.find_by_sql("select product_id from comments where score == 111.0")
    if !@toptens.nil?
        @goodsongs = []
        @toptens.each do |topten|
            @goodsongs << Product.find_by_id(topten.product_id)
        end
    end
  end

  def edit
      @product = Product.find_by_id(params[:id])
  end

  def update
     @product = Product.find_by_id(params[:id])
     if !@product.nil? and @product.update_attributes(params[:product])
        flash[:success] = "图书信息更新成功!"
        redirect_to @product
      else
        flash[:warning] = "图书信息更新失败!"
        redirect_to edit_product_path
      end
  end

  def show
  	@product = Product.find(params[:id])
  	@comments = @product.comments.paginate(page: params[:page], :per_page => 10) 

  	if !sign_in?	
  		store_url
  	else
      if !create_order?
        store_url
      end
    end
  end

  def search
	  @goodsongs = Sunspot.search(Product) do
		  keywords params[:query] do
        fields(:title)
      end
      order_by :created_at, :desc
    end.results

	  respond_to do |format|
		  format.html {render :action =>"index" }
		  format.xml { render :xml => @goodsongs }
	  end
  end

  def destroy
      @product = current_buyer.products.find_by_id(params[:id])
      if @product.flag == 'y' #表示图书未被借出
         current_buyer.products.find_by_id(params[:id]).destroy #删除
         respond_to do |format|
            format.html {redirect_to managemybooks_buyers_path}
            format.js
         end
      else
         flash[:warning] = "图书借出未归还,无法删除!"
         render managemybooks_buyers_path
      end
  end
end
