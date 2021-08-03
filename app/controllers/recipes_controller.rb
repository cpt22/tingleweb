class RecipesController < ApplicationController
  before_action :authorize_recipes

  def index
    @recipes = Recipe.all
  end

  def new
  end

  def create
    if @recipe.update(permitted_attributes(Recipe))
      flash[:notice] = "Recipe created."
      redirect_to recipes_path
    else
      flash[:error] = "Recipe could not be created."
      render :action => :new
    end
  end

  def edit
  end

  def update
    attrs = permitted_attributes(@recipe)
    attrs[:recipe_ingredients_attributes].values.select{|v| v[:ingredient_id].blank?}.each do |v|
      if v[:ingredient_name].present?
        v[:ingredient_id] = Ingredient.find_or_create_by(name: v[:ingredient_name]).id
      end
    end
    byebug
    if @recipe.update(attrs)
      flash[:notice] = "Recipe updated."
      redirect_to edit_recipe_path(@recipe)
    else
      flash[:error] = "Recipe could not be updated."
      render :action => :edit
    end
  end

  def delete
    begin
      flash[:notice] = "The recipe was deleted."
    rescue Exception => e
      flash[:error] = "The recipe could not be deleted. #{e.to_s}"
    end
    redirect_to recipes_path
  end

private

  def authorize_recipes
    case params[:action].to_sym
    when :new, :create
      @recipe = Recipe.new(user: current_user)
    when :edit, :update, :destroy
      @recipe = Recipe.find(params[:id])
    end
    authorize @recipe || Recipe
  end
end
