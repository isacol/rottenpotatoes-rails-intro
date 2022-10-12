class MoviesController < ApplicationController

    def show
      id = params[:id] # retrieve movie ID from URI route
      @movie = Movie.find(id) # look up movie by unique ID
      # will render app/views/movies/show.<extension> by default
    end
  
    #only save param if id is what you want it to be - if filter id is = to ___ , save param in session

    #case 1: nothing in param or session
    #  run the defaults - all ratings, and no filter
    #case 2: something in param PERIOD --> run with that param, reset session
    #case 3: something in session thats not in param 

    # if exsits sort/filter in params or session 

    #(something in the session, something in the param, nothing)
    def index
      #@movies = Movie.all
      @all_ratings = Movie.all_ratings
      @ratings_to_show = []

      # if params[:ratings].nil? and params[:sort].nil? # if new call doesnt have params sort or ratings
      #   if session[:ratings].nil?
      #     ratings = session[:ratings]
      #     redirect_to movies_path(:ratings => ratings)
      #   elsif session[:sort].nil?
      #     sort = session[:sort]
      #     redirect_to movies_path(:sort => sort)
      # end

      if !params.has_key?(:ratings) and !params.has_key(:sort):
        if session.has_key(:ratings)
          ratings = session[:ratings]
        end
        if
      elsif params.has_key?(:ratings) and !params.has_key?(:sort)
        session[:ratings] = params[:ratings]
        if session.key?(:sort)
          sort = session[:ratings]
          ratings = params[:ratings]
          redirect_to movies_path(:sort => sort, :ratings => ratings)
        end
      elsif params.has_key?(:sort) and !params.has_key(:ratings)
        session[:sort] = params[:sort]
        if session.key?(:ratings)
          ratings = session[:ratings]
          sort = params[:sort]
          redirect_to movies_path(:sort => sort, :ratings => ratings)
        end
      end


      #BELOW = PURE CODE. dont touch - ensure cases before this hit
      if params.has_key?(:ratings)
        @ratings_to_show = params[:ratings].keys()
        @ratings_to_show_hash = Hash[@ratings_to_show.map {|k| [k, '1']}]
      end
      
      @movies = Movie.with_ratings(@ratings_to_show)

      @title_header = ''
      @release_date_header = ''

      if params.has_key?(:sort)
        @movies = @movies.order(params[:sort])
        if params[:sort] == 'title'
          @title_bg = 'hilite bg-warning'
        end
        if params[:sort] == 'release_date'
          @release_date_bg = 'hilite bg-warning'
        end
      end

    end
  
    def new
      # default: render 'new' template
    end
  
    def create
      @movie = Movie.create!(movie_params)
      flash[:notice] = "#{@movie.title} was successfully created."
      redirect_to movies_path
    end
  
    def edit
      @movie = Movie.find params[:id]
    end
  
    def update
      @movie = Movie.find params[:id]
      @movie.update_attributes!(movie_params)
      flash[:notice] = "#{@movie.title} was successfully updated."
      redirect_to movie_path(@movie)
    end
  
    def destroy
      @movie = Movie.find(params[:id])
      @movie.destroy
      flash[:notice] = "Movie '#{@movie.title}' deleted."
      redirect_to movies_path
    end
  
    private
    # Making "internal" methods private is not required, but is a common practice.
    # This helps make clear which methods respond to requests, and which ones do not.
    def movie_params
      params.require(:movie).permit(:title, :rating, :description, :release_date)
    end
  end