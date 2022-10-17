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
      @all_ratings = Movie.all_ratings
      @ratings_to_show = @all_ratings
      if !params.key?(:ratings) and !params.has_key?(:sort)
        if session.key?(:ratings)
          @ratings = session[:ratings]
          redirect_to movies_path(ratings: @ratings) and return
        end
        if session.key?(:sort)
          @sort = session[:sort]
          redirect_to movies_path(sort: @sort) and return
        end
      end

      if params.has_key?(:ratings) and !params.has_key?(:sort)
        session[:ratings] = params[:ratings]
        if session.key?(:sort)
          @sort = session[:sort]
          @ratings = params[:ratings]
          redirect_to movies_path(sort: @sort, ratings: @ratings) and return
        end
      end
      
      if params.has_key?(:sort) and !params.has_key?(:ratings)
        session[:sort] = params[:sort]
        if session.key?(:ratings)
          @ratings = session[:ratings]
          @sort = params[:sort]
          redirect_to movies_path(sort: @sort, ratings: @ratings) and return
        end
      end
      ############
      if params.key?(:ratings)
        @ratings_to_show = params[:ratings].keys()
        # @ratings_to_show_hash = Hash[@ratings_to_show.map {|k| [k, 1]}]
      end

      @movies = Movie.with_ratings(@ratings_to_show)

      @title_header = ''
      @release_date_header = ''

      if params.has_key?(:sort)
        session[:sort] = params[:sort]
        #@movies = @movies.order(params[:sort])
        if params[:sort] == 'title'
          @movies = @movies.order('title')
          @title_bg = 'hilite bg-warning'
        end
        if params[:sort] == 'release_date'
          @movies = @movies.order('release_date')
          @release_date_bg = 'hilite bg-warning'
        end
      end

      #BELOW = PURE CODE. dont touch - ensure cases before this hit
      # if params[:ratings].nil? == false #params.has_key?(:ratings)
      #   @ratings_to_show = params[:ratings].keys()
      #   @ratings_to_show_hash = Hash[@ratings_to_show.map {|k| [k, '1']}]
      # end
      
      # @movies = Movie.with_ratings(@ratings_to_show)

      # @title_header = ''
      # @release_date_header = ''

      # if params.has_key?(:sort)
      #   @movies = @movies.order(params[:sort])
      #   if params[:sort] == 'title'
      #     @title_bg = 'hilite bg-warning'
      #     #@movies = @movies.order(:title)
      #   end
      #   if params[:sort] == 'release_date'
      #     @release_date_bg = 'hilite bg-warning'
      #     #@movies = @movies.order(:release_date)
      #   end
      # end

    end

    def index_f
      @all_ratings = Movie.all_ratings
      @ratings_to_show = [] #@all_ratings
      # @ratings_to_show_hash = Hash[@ratings_to_show.map {|k| [k, 1]}]

      # ratings = ''
      # sort = ''
      if params.key?(:ratings) and (params[:ratings].is_a?(Hash) == false)
        @h = params[:ratings]
        params[:ratings] = Hash[@h.map {|k| [k, 1]}]
      end

      if params.key?(:ratings)
        session[:ratings] = params[:ratings]
        @ratings_to_show = params[:ratings].keys()
        # @ratings_to_show_hash = Hash[@ratings_to_show.map {|k| [k, 1]}]
      elsif session.key?(:ratings)
        ratings = session[:ratings]
        redirect_to movies_path(ratings: ratings) #and return
    
      else
        @ratings_to_show = @all_ratings
        # @ratings_to_show_hash = Hash[@ratings_to_show.map {|k| [k, 1]}]
      end

      @movies = Movie.with_ratings(@ratings_to_show)

      @title_header = ''
      @release_date_header = ''

      if params.key?(:sort)
        #@movies = @movies.order(params[:sort])
        session[:sort] = params[:sort]
        if params[:sort] == 'title'
          @movies = @movies.order('title')
          @title_bg = 'hilite bg-warning'
        end
        if params[:sort] == 'release_date'
          @movies = @movies.order('release_date')
          @release_date_bg = 'hilite bg-warning'
        end
      elsif session.key?(:sort)
        sort = session[:sort]
        redirect_to movies_path(:sort => sort) #and return
      else 
        return
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