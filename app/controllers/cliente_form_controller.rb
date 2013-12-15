class ClienteFormController < Formotion::FormController
  
  def init
    form = Formotion::Form.new({
      sections: [{
        title: "Cliente",
        rows: [{
          title: "Nome",
          key: :nome,
          value: @cliente.nome,
          placeholder: "nome cliente",
          type: :string
        },{
          title: "Tipo",
          type: :subform,
          key: :cliente_tipo,
          display_key: :type,
          subform: {
            sections: [{
              key: :type,
              select_one: true,
              rows: tipi_clienti_rows
            }, {
              rows: [{
                title: 'Indietro',
                type: :back
              }]
            }]
          }
        }, {
          title: "comune",
          key: :comune,
          type: :string,
          value: @cliente.comune
        }, {
          title: "frazione",
          key: :frazione,
          type: :string,
          value: @cliente.frazione
        }, {
          title: "provincia",
          key: :provincia,
          type: :string,
          value: @cliente.provincia
        }, {
          title: "indirizzo",
          key: :indirizzo,
          type: :string,
          value: @cliente.indirizzo
        }, {
          title: "cap",
          key: :cap,
          type: :number,
          value: @cliente.cap
        }]
      }, {
        rows: [{
          title: "Submit",
          type: :submit,
        }]
      }]
    })
    form.on_submit do
      self.submit
    end
    super.initWithForm(form)
  end

  def initWithCliente(cliente)
    @cliente = cliente
    init
    self
  end

  def viewDidLoad
    super
    self.navigationItem.leftBarButtonItem = UIBarButtonItem.cancel do |button|
      self.navigationController.dismissModalViewControllerAnimated(true)
    end  
  end

  def submit
    [:cliente_tipo].each { |prop|
      @cliente.send(prop.to_s + "=", form.render[prop][:type])
    }

    [:nome, :comune, :frazione, :provincia, :cap, :indirizzo].each { |prop|
      @cliente.send(prop.to_s + "=", form.render[prop])
    }

    self.navigationController.popViewControllerAnimated(true)
  end

  private

    def tipi_clienti_rows

      tipi = []
      
      TIPI_CLIENTI.each do |tipo|

        true_value = tipo == @cliente.cliente_tipo ? true : false 

        tipi << {
          title: tipo,
          key: tipo.to_sym,
          type: :check,
          value: true_value          
        }

      end

      tipi

    end

end