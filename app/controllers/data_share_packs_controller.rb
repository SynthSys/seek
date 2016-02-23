class DataSharePacksController < ApplicationController


  @@knownFunders = %w(BBSRC EPSRC)

  @@knownLicenses = ['Creative Commons Attribution 4.0 International licence']

  @@knownCollections = ['Sword','Wrong']

  @@knownPublishers = ['University of Edinburgh. School of Biology']

  @@knownSetTypes = ['dataset']
  # GET /data_share_packs
  # GET /data_share_packs.json
  def index
    @data_share_packs = DataSharePack.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @data_share_packs }
    end
  end

  # GET /data_share_packs/1
  # GET /data_share_packs/1.json
  def show
    @data_share_pack = DataSharePack.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @data_share_pack }
    end
  end

  # GET /data_share_packs/new
  # GET /data_share_packs/new.json
  def new

    logger.info "\nNew data pack with snapshot id: #{params[:snapshot_id]}\n"

    snapshot =  Snapshot.find(params[:snapshot_id])
    @data_share_pack = DataSharePack.new
    @data_share_pack.title =snapshot.parent.title
    @data_share_pack.description=snapshot.parent.description
    @data_share_pack.snapshot = snapshot

    @funders = @@knownFunders
    @licences = @@knownLicenses
    @collections = @@knownCollections
    @publishers = @@knownPublishers
    @setTypes = @@knownSetTypes

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @data_share_pack }
    end
  end

  # GET /data_share_packs/1/edit
  def edit
    @data_share_pack = DataSharePack.find(params[:id])
  end

  # POST /data_share_packs
  # POST /data_share_packs.json
  def create
    @data_share_pack = DataSharePack.new(params[:data_share_pack])

    depositor = current_person.name

    @data_share_pack.depositor = depositor
    @data_share_pack.status = 1

    respond_to do |format|

      if @data_share_pack.save
        #SwordExportJob.new(@data_share_pack).queue_job
        begin
          logger.info "\nSending new deposit of : #{@data_share_pack.id}\n"

          resp = Synthsys::Dspace::DspaceUploaderConnector.INSTANCE.deposit(@data_share_pack)

          format.html { redirect_to @data_share_pack, notice: "Request for DataShare export was exported: #{resp}." }
          format.json { render json: @data_share_pack, status: :created, location: @data_share_pack }

        rescue Exception => e
          logger.error "ERROR in deposit: #{e}"
          e.backtrace.each do |s|
            logger.error(s)
          end
          @data_share_pack.errors.add(:collection,"DEPOSIT ERROR #{e}")
          format.html { render action: "new" }
          format.json { render json: @data_share_pack.errors, status: :unprocessable_entity }
        end


        #format.html { redirect_to @data_share_pack, notice: 'Request for DataShare export was queued.' }
        #format.json { render json: @data_share_pack, status: :created, location: @data_share_pack }
      else
        logger.error "ERROR: #{@data_share_pack.errors.full_messages}"
        format.html { render action: "new" }
        format.json { render json: @data_share_pack.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /data_share_packs/1
  # PUT /data_share_packs/1.json
=begin
  def update
    @data_share_pack = DataSharePack.find(params[:id])

    logger.info "UPDATE"
    logger.info params[:data_share_pack]
    respond_to do |format|
      if @data_share_pack.update_attributes(params[:data_share_pack])
        logger.info "In update"
        format.html { redirect_to @data_share_pack, notice: 'Data share pack was successfully updated.' }
        format.json { head :no_content }
      else
        logger.info "No update"
        format.html { render action: "edit" }
        format.json { render json: @data_share_pack.errors, status: :unprocessable_entity }
      end
    end
  end
=end

  # DELETE /data_share_packs/1
  # DELETE /data_share_packs/1.json
  def destroy
    @data_share_pack = DataSharePack.find(params[:id])
    @data_share_pack.destroy

    respond_to do |format|
      format.html { redirect_to data_share_packs_url }
      format.json { head :no_content }
    end
  end


end
