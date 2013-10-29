class MainController < UIViewController

  extend IB

  outlet :menuView
  outlet :detailView

  attr_accessor :menuVC, :detailVC, :searchVC


  def viewDidLoad
    super

    self.searchVC.detailVC = detailVC

    c = NSLayoutConstraint.constraintWithItem(menuView,
                                            attribute: NSLayoutAttributeWidth,
                                            relatedBy: NSLayoutRelationEqual,
                                            toItem: detailView,
                                            attribute: NSLayoutAttributeWidth,
                                            multiplier:0.5,
                                            constant:0)

    self.view.addConstraint c

    #self.menuVC.detailVC = detailVC
    #self.searchDisplayController.searchResultsTableView.registerClass(ClienteCell, forCellReuseIdentifier:"cellCliente")
  
  end

  def preferredStatusBarStyle
    UIStatusBarStyleLightContent
  end

  def prepareForSegue(segue, sender:sender)
    if (segue.identifier.isEqualToString("searchSegue"))  
      self.searchVC = segue.destinationViewController
      self.searchVC.mainVC = self
    elsif (segue.identifier.isEqualToString("detailSegue"))
      self.detailVC = segue.destinationViewController
    end
  end

  # toolbar actions

  def importa(sender)
    @actionSheet = UIActionSheet.alloc.initWithTitle("Sei sicuro?",
                                            delegate:self,
                                        cancelButtonTitle:"Annulla",
                                        destructiveButtonTitle:"Importa",
                                        otherButtonTitles:nil)

    @actionSheet.showInView(self.view, animated:true)
  end


  def actionSheet(actionSheet, didDismissWithButtonIndex:buttonIndex)
    if buttonIndex != @actionSheet.cancelButtonIndex
      esegui_importazione
    end
    @actionSheet = nil
  end

  def login(sender)
    Store.shared.login {}
  end

  def esegui_importazione
    #self.activityIndicator.startAnimating
    
    Store.shared.clear

    @importer = DataImporter.default
    
    @importer.importa_clienti do |result|
      #   Store.shared.persist
      #   @importer.importa_appunti do |result|
      #     Store.shared.persist
      #   end
      # end
      # main_queue = Dispatch::Queue.main
      # main_queue.async do
      #   "reload_annotations".post_notification

      @importer.importa_classi do |result|
        @importer.importa_libri do |result|
          @importer.importa_adozioni do |result|
            @importer.importa_appunti do |result|
               @importer.importa_righe do |result|               
                Store.shared.persist
                puts "finito"
                # self.activityIndicator.stopAnimating
                @importer = nil
              end
            end
          end
        end
      end
    end
  end


end