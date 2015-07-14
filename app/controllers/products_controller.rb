class ProductsController < ApplicationController
  def new
    @product = Product.new(buyer_id: current_buyer.id)
  end

  def create
    @new_product = current_buyer.products.build(params[:product])
    if @new_product.save
      redirect_to current_buyer
    else
      render new_product_path
    end
  end

  def index
    @toptens = Comment.find_by_sql("select product_id from comments where score == 5.0")
    if !@toptens.nil?
        @goodsongs = []
        @toptens.each do |topten|
            @goodsongs << Product.find_by_id(topten.product_id)
        end
    end
  end
  
  def show
  	@product = Product.find(params[:id])
  	@comments = @product.comments.paginate(page: params[:page], :per_page => 10) 

  	if !sign_in?	
  		store_url
  	else 
       #use k-jinlin algorithm here
      #@toptens_id, @is_k_method = recommend_songs(@comments, @product.flag)

      #if !@toptens_id.nil?
      #    @goodsongs = []
      #    @toptens_id.each do |topten|
      #        @goodsongs << Product.find_by_id(topten)
      #    end
      #end
      
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
end
