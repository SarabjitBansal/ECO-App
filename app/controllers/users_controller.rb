class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  before_action :require_user, except:[:new,:create]
  before_action :require_same_user, only: [:edit, :update, :destroy] #cannot delete another user's account


  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)



    respond_to do |format|
      if @user.save
        if @user.image?
          @cloudinary = Cloudinary::Uploader.upload(params[:user][:image])
          @user.update :image => @cloudinary['url']
        end
        session[:user_id] = @user.id
        cookies.signed[:user_id] = @user.id
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # add session for user authentication.
  # add cookies add cookies for ActionCable connection.

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        if @user.image?
          @cloudinary = Cloudinary::Uploader.upload(params[:user][:image])
          @user.update :image => @cloudinary['url']
        end
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def scoreboard
    # custom methods from model
    # @users = User.all.sort_by(&:score).reverse # @user.score
    @users = User.where.not(name: 'Admin').sort_by(&:score).reverse # @user.score
    # @level = @user.level
    # @leaders = User.all.order(:level)
  end

  def following
    @title = "Following"
    @user  = User.find(params[:id])
    @users = @user.following
    render 'show_follow'
  end

  def followers
      @title = "Followers"
      @user  = User.find(params[:id])
      @users = @user.followers
      render 'show_follow'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:name, :email, :image, :password, :password_confirmation, :location, :admin, task_ids: [], achievement_ids: [])
    end

    def require_same_user
      user = User.find(params[:id])
      if current_user != user && current_user.admin != false
        redirect_to users_path
      end
    end

end
