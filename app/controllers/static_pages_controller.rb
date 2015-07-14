class StaticPagesController < ApplicationController
	def home
		@products = Product.paginate(page: params[:page], :per_page => 16)

		session.delete(:return_to)
		@product = Product.new

	end

  private 
    #when a user sign in, create a pool of recommended songs that he may like,
	#which are deal with by the offline method.
	def fill_in_recommend_songs
		songs_pool = []
		count = 0
		users_songs = IO.readlines("/home/xieyizun/ai/music/app/assets/recommend/offline") 
		users_songs.each do |line|
			user_song = line.split(' ')
			if user_song.first.to_i == current_buyer.id and count <= 100
				songs_pool << user_song.last.to_i
				count += 1
				if count > 100
				   break
				end		
			end
		end
		return songs_pool
	end	
end
