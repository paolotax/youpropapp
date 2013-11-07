class ClienteDetailController < UIViewController

  extend IB
  
  outlet :tableView

  attr_accessor :cliente
  attr_accessor :refreshControl
  attr_accessor :titolo

  def viewDidLoad
    super
 
    @refreshControl = UIRefreshControl.alloc.init
    @refreshControl.addTarget(self, action:"loadFromBackend", forControlEvents:UIControlEventValueChanged)
    self.tableView.addSubview(@refreshControl)

    #self.tableView.registerClass(AppuntoCell, forCellReuseIdentifier:"cellAppunto")

  end

  def viewDidAppear(animated)
    super
    "#{titolo}changeTitolo".post_notification( self, titolo: cliente.nome, sottotitolo: nil )

    NSNotificationCenter.defaultCenter.addObserver(self,
                                             selector:"contentSizeCategoryChanged:",
                                                 name:UIContentSizeCategoryDidChangeNotification,
                                               object:nil)

    reload
  end


  def viewDidDisappear(animated)
    super
    NSNotificationCenter.defaultCenter.removeObserver(self,
                                                    name:UIContentSizeCategoryDidChangeNotification,
                                                  object:nil)
  end


  def contentSizeCategoryChanged(notification)
    puts "contentSizeCategoryChanged"
    self.tableView.reloadData
  end

  def reload
    @sorted_appunti = nil
    @appunti_da_fare = nil
    @appunti_in_sospeso = nil
    @appunti_completati = nil
    self.tableView.reloadData
  end


  def appunti_da_fare
    @appunti_da_fare = []
    @appunti_da_fare = sorted_appunti.select { |a| a.status != "completato" && a.status != "in_sospeso" }
    @appunti_da_fare
  end

  def appunti_in_sospeso
    @appunti_in_sospeso = [] 
    @appunti_in_sospeso = sorted_appunti.select { |a| a.status == "in_sospeso" }
    @appunti_in_sospeso
  end

  def appunti_completati
    @appunti_completati = [] 
    @appunti_completati = sorted_appunti.select { |a| a.status == "completato" }
    @appunti_completati
  end

  def sorted_appunti
    @sorted_appunti = []
    orderAppunti = NSSortDescriptor.sortDescriptorWithKey("created_at", ascending:false)
    @sorted_appunti = cliente.appunti.sortedArrayUsingDescriptors([orderAppunti])
    @sorted_appunti
  end

  # Storyboard methods
  def prepareForSegue(segue, sender:sender)
    
    if segue.identifier.isEqualToString("newAppunto")
      controller = segue.destinationViewController.topViewController
      controller.cliente = cliente
      controller.isNew = true
      controller.presentedAsModal = true
    
    elsif segue.identifier.isEqualToString("editAppunto")
      controller = segue.destinationViewController.topViewController
      controller.cliente = cliente
      indexPath = self.tableView.indexPathForCell(sender)
      if indexPath.section == 0
        appunto = appunti_da_fare.objectAtIndex( indexPath.row )
      elsif indexPath.section == 1
        appunto = appunti_in_sospeso.objectAtIndex( indexPath.row )
      else
        appunto = appunti_completati.objectAtIndex( indexPath.row )
      end
      controller.appunto = appunto
      controller.isNew = false
      controller.presentedAsModal = true
    end
  end


  def numberOfSectionsInTableView(tableView)
    if cliente 
      3
    else
      0
    end
  end
  
  def tableView(tableView, numberOfRowsInSection:section)
    if cliente
      if section == 0
        appunti_da_fare.count
      elsif section == 1
        appunti_in_sospeso.count
      else
        appunti_completati.count
      end
    else
      0
    end
  end

  def tableView(tableView, cellForRowAtIndexPath:indexPath)
   
    cell = tableView.dequeueReusableCellWithIdentifier("cellAppunto", forIndexPath:indexPath)
    
    #cell.updateFonts
    
    if indexPath.section == 0
      appunto = appunti_da_fare.objectAtIndex( indexPath.row )
    elsif indexPath.section == 1
      appunto = appunti_in_sospeso.objectAtIndex( indexPath.row )
    else
      appunto = appunti_completati.objectAtIndex( indexPath.row )
    end    
    
    cell.labelDestinatario.text =  appunto.destinatario
    cell.labelNote.text = appunto.note_e_righe
    
    if appunto.totale_copie != 0
      cell.labelTotali.text = "#{appunto.totale_copie} copie - € #{appunto.totale_importo.round(2)}"
    else
      cell.labelTotali.text = nil
    end

    if appunto.status == "completato"
      cell.imageStatus.image = "completato".uiimage
      cell.imageStatus.highlightedImage = "completato".uiimage
    elsif appunto.status == "in_sospeso"
      cell.imageStatus.image = "826-money-1".uiimage
      cell.imageStatus.highlightedImage = "826-money-1-selected".uiimage
    else
      cell.imageStatus.image = nil
      cell.imageStatus.highlightedImage = nil
    end

    #cell.setNeedsUpdateConstraints
    cell
  end

  def tableView(tableView, heightForRowAtIndexPath:indexPath)

    if indexPath.section == 0
      appunto = appunti_da_fare.objectAtIndex( indexPath.row )
    elsif indexPath.section == 1
      appunto = appunti_in_sospeso.objectAtIndex( indexPath.row )
    else
      appunto = appunti_completati.objectAtIndex( indexPath.row )
    end     

    font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
    noteText = appunto.note_e_righe

    boundingRect = noteText.boundingRectWithSize(CGSizeMake(150, 4000),
                                   options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading),
                                attributes:{ NSFontAttributeName: font },
                                  context:nil)
    boundingSize = boundingRect.size

    puts "boundingSize height #{boundingSize.height} width #{boundingSize.width}"
    
    return ( 60 + boundingSize.height)

    # NON CANCELLARE 
    # cell = tableView.dequeueReusableCellWithIdentifier("cellAppuntoAuto")
    
    # cell.updateFonts
    
    # if indexPath.section == 0
    #   appunto = appunti_da_fare.objectAtIndex( indexPath.row )
    # elsif indexPath.section == 1
    #   appunto = appunti_in_sospeso.objectAtIndex( indexPath.row )
    # else
    #   appunto = appunti_completati.objectAtIndex( indexPath.row )
    # end     

    # cell.labelDestinatario.text =  appunto.destinatario
    # cell.labelNote.text = appunto.note_e_righe
    
    # cell.labelNote.preferredMaxLayoutWidth = tableView.bounds.size.width - (78.0)
    
    # if appunto.totale_copie != 0
    #   cell.labelTotali.text = "#{appunto.totale_copie} copie - € #{appunto.totale_importo.round(2)}"
    # else
    #   cell.labelTotali.text = nil
    # end

    # cell.setNeedsUpdateConstraints
    # cell.updateConstraintsIfNeeded
    # cell.contentView.setNeedsLayout
    # cell.contentView.layoutIfNeeded
    
    # height = cell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height    
    
    # height = [height, 48].max
    # height
  end

  def tableView(tableView, titleForHeaderInSection:section)
    if section == 0
      "da fare"
    elsif section == 1
      "in sospeso"
    else
      "completati"
    end
  end

  def tableView(tableView, estimatedHeightForRowAtIndexPath:indexPath)
    100
  end


  private

    def loadFromBackend
      params = { q: cliente.ClienteId }
      DataImporter.default.importa_appunti(params) do |result|
        @refreshControl.endRefreshing unless @refreshControl.nil?
        if result.success?
          self.tableView.reloadData
        end  
      end
    end


end