class DsPacksController < ApplicationController

  # GET /ds_packs/new?assay_id=X
  def new
    logger.info "\n\nNew data pack with assay id: #{params[:assay_id]}\n\n"

    #@assay =  nil
    @assay =  Assay.find(params[:assay_id])
    @ds_pack = DsPack.new
    @ds_pack.title = @assay.title
    @ds_pack.description = @assay.description
    @ds_pack.assay = @assay

    #respond_to do |format|
    #  format.html # new.html.erb
    #  format.json { render json: @data_share_pack }
    #end
  end

  def create
  end
end
