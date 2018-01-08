class WelcomeController < ApplicationController
  def index
  end

  def login
  end

  def celebrity
    @celebrity = Celebrity.new
  end

  def view_celebrity
    @celebrity = Celebrity.find params[:id]
  end

  def create_celebrity
    celebrity = Celebrity.create celebrity_params
    redirect_to action: "view_celebrity", id: celebrity.id
  end

  def celebrity_params
    params.require(:celebrity).permit(:name, :website, :twitter, :bio, :photo)
  end
end
