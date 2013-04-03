require 'lims-core/laboratory/gel/gel_persistor'
require 'lims-core/persistence/sequel/persistor'
require 'lims-core/laboratory/container/container_sequel_persistor'
require 'lims-core/laboratory/container/container_element_sequel_persistor'

module Lims::Core
  module Laboratory
    # A gel persistor. It saves the gel's data to the DB.
    class Gel
      class GelSequelPersistor < GelPersistor
        include Sequel::Persistor
        include Container

        module Gel::GelSequelPersistorContainerElement
          include ContainerElement

          def element_dataset
            Lims::Core::Persistence::Sequel::Gel::Window::dataset(@session)
          end

          def container_id_sym
            :gel_id
          end

        end

        # A window persistor. It saves the window's data to the DB.
        class Window < Persistence::Gel::Window
          include Sequel::Persistor
          include GelContainerElement

          def self.table_name
            :windows
          end

        end 
        #class Window

        def self.table_name
          :gels
        end

        def container_id_sym
          :gel_id
        end

        def element_dataset
          Window::dataset(@session)
        end
      end
    end
  end
end
