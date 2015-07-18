class Product < ActiveRecord::Base
	attr_accessible :title, :description, :image_url, :price, :music_url, :flag, :buyer_id
	belongs_to :buyer
	has_many :items, dependent: :destroy
	has_many :comments, dependent: :destroy
	#设置完之后记得执行: rake sunspot:solr:reindex
	searchable do
		text :title, :description
		
		time :created_at	
	end
end
