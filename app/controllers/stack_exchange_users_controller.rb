class StackExchangeUsersController < ApplicationController
  before_action :set_stack_exchange_user, :only => [:show]

  def index
    @users = StackExchangeUser.joins(:feedbacks).where("still_alive = true").where("stack_exchange_users.site_id = 1").where("feedbacks.feedback_type LIKE '%t%'").includes(:site).group(:user_id).order("created_at DESC").first(100)
  end

  def show
    @posts = @user.posts
  end

  def on_site
    @site = Site.find params[:site]
    @users = StackExchangeUser.joins(:feedbacks).where(:site => @site, :still_alive => true)
                              .where("feedbacks.feedback_type LIKE '%t%'").group('stack_exchange_users.id')
                              .order('(stack_exchange_users.question_count + stack_exchange_users.answer_count) DESC, stack_exchange_users.reputation DESC')
                              .paginate(:page => params[:page], :per_page => 100)
  end

  def sites
    @sites = Site.all
  end

  def dead
    @user = StackExchangeUser.find params[:id]
    if @user.update(:still_alive => false)
      render :plain => "ok"
    else
      render :plain => "fail"
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_stack_exchange_user
      begin
        @user = StackExchangeUser.joins(:site).select("stack_exchange_users.*, sites.site_logo").find(params[:id])
      rescue
        @user = StackExchangeUser.find(params[:id])
      end
    end
end
