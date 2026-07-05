class Admin::SynonymsController < Admin::BaseController
  before_action :set_synonym, only: [ :update, :destroy ]

  def index
    @synonyms = SearchSynonym.order(:term)
    @synonym = SearchSynonym.new
  end

  def create
    @synonym = SearchSynonym.new(synonym_params)
    if @synonym.save
      redirect_to admin_synonyms_path, notice: "Sinónimo agregado."
    else
      @synonyms = SearchSynonym.order(:term)
      render :index, status: :unprocessable_entity
    end
  end

  def update
    if @synonym.update(synonym_params)
      redirect_to admin_synonyms_path, notice: "Sinónimo actualizado."
    else
      @synonyms = SearchSynonym.order(:term)
      @synonym = SearchSynonym.new
      render :index, status: :unprocessable_entity
    end
  end

  def destroy
    @synonym.destroy
    redirect_to admin_synonyms_path, notice: "Sinónimo eliminado."
  end

  private

  def set_synonym
    @synonym = SearchSynonym.find(params[:id])
  end

  def synonym_params
    params.require(:search_synonym).permit(:term, :keywords)
  end
end
