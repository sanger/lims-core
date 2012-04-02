# vi: ts=2:sts=2:et:sw=2

require 'common'
require 'forwardable'


module Lims::Core
    module  Persistence
      # A session is in charge of restoring and saving object throug the persistence layer.
      # A Session can not normally be created by the end user. It has to be in a Store::with_session
      # block, which acts has a transaction and save/update everything at the end of it.
      # It should also provides an identity map.
      # Session information (user, time) are also associated to the modifications of those objects.
      class Session
        extend Forwardable
        # param [Store] store the underlying store.
        def initialize(store)
          @store = store
          @objects = Set.new
          @in_session = false
          @saved = Set.new
          @persistor_map = {}
        end

        def_delegators :@store, :database

        # Execute a block and save every 'marked' object
        # in a transaction at the end.
        # @yieldparam [Session] session the created session.
        # @return the value of the block
        def with_session(*params, &block)
          @in_session = true
          to_return = block[self]
          @in_session = false
          save_all
          return to_return
        ensure
          @in_session = false
        end


        # Tell the session to be responsible of an object.
        # The object will be saved at the end of the session.
        # @example
        #   store.with_session do |session|
        #     session << Plate.new
        #   end
        # @param [Persistable] object the object to persist.
        # @return  the object itself.
        def << (object)
          @objects << object
        end

        # save the object in real.
        # To mark an object as 'to save' use the `<<` method
        # Note we can't make this method private because, the persistor
        # need it to save their children. To solve this, we raise an exception if it's inside a sess
        # @return [Boolean]
        def save(object, *options)
          raise RuntimeError, "Can't save object inside a session. Please considere the << methods." unless @save_in_progress
          return if @saved.include?(object)
          @saved << object

          persistor_for(object).save(object, *options)
        end

        def method_missing(name, *args, &block)
          persistor_for(name) || super(name, *args, &block)
        end

        # Called by Persistor to inform the session
        # about the loading of an object.
        # MUST be called by persistors creating Resources.
        def on_object_load(object)
          self << object
        end

        private
        # save all objects which needs to be
        def save_all()
          @save_in_progress = true # allows saving
          @objects.each do |object|
            save(object)
          end
          @save_in_progress = false
        end

        # Get the persistor corresponding to the object class
        # @param [Resource] object
        # @return [Persistor, nil]
        def persistor_for(object)
          name = persistor_name_for(object)
          @persistor_map[name]  ||= \
            begin
              @store.base_module.constant(name).new( self)
            rescue NameError
              nil
            end
        end

        # Compute the class name of the persistor corresponding to the argument
        # @param [Resource]
        # @return [String]
        def  persistor_name_for(object)
          case object
          when String then object
          when Symbol then object.to_s
          else object.class.name.sub(/^Lims::Core::\w+::/, '')
          end.upper_camelcase
        end
      end
    end
end
