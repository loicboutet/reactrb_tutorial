class TodosController < ApplicationController
  before_action :set_todo, only: [:show, :edit, :update, :destroy]

  # GET /todos
  # GET /todos.json
  def index
    @todos = Todo.all
    @scope = "all"
    if %w(active complete).include?(params[:scope])
      @todos = @todos.send(params[:scope].to_sym)
      @scope = params[:scope]
    end
    @uncomplete_todo = Todo.active
  end

  # GET /todos/new
  def new
    @todo = Todo.new
    @title = "New Todo"
  end

  # GET /todos/1/edit
  def edit
    @title = "Edit Todo"
  end

  # POST /todos
  def create
    @todo = Todo.new(todo_params)
    if @todo.save
      redirect_to todos_url
    else
      render :new
    end
  end

  # PATCH/PUT /todos/1
  def update
    if @todo.update(todo_params)
      redirect_to todos_url
    else
      render :edit
    end
  end

  # DELETE /todos/1
  def destroy
    @todo.destroy
    redirect_to todos_url
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_todo
      @todo = Todo.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def todo_params
      params.require(:todo).permit(:title, :complete)
    end
end
