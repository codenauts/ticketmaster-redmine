module TicketMaster::Provider
  module Redmine
    # Project class for ticketmaster-yoursystem
    # 
    # 
    class Project < TicketMaster::Provider::Base::Project
      # declare needed overloaded methods here
      API = RedmineAPI::Project      
      LIMIT = 100

      def initialize(*object) 
        if object.first
          object = object.first
          unless object.is_a? Hash
            hash = {:id => object.id,
                    :name => object.name,
                    :description => object.description,
                    :identifier => object.identifier,
                    :parent => (object.respond_to?(:parent) && object.parent.present? ? object.parent.id : nil),
                    :created_at => object.created_on,
                    :updated_at => object.updated_on}

          else
            hash = object
          end
          super hash
        end
      end
            
      def self.find_for_page(page)
        API.find(:all, :params => { :limit => LIMIT, :page => page }).collect do |project|
          Project.new project
        end
      end
      
      def self.all
        projects = []
        5.times do |page|
          projects += find_for_page(page + 1)
          break if projects.count < (page + 1) * LIMIT
        end
        projects
      end
      
      # copy from this.copy(that) copies that into this
      def copy(project)
        project.tickets.each do |ticket|
          copy_ticket = self.ticket!(:title => ticket.title, :description => ticket.description)
          ticket.comments.each do |comment|
            copy_ticket.comment!(:body => comment.body)
            sleep 1
          end
        end
      end

      def id
        self[:id]
      end

      def identifier
        self[:identifier]
      end

      def tickets(*options)
        begin 
        if options.first.is_a? Hash
          options[0].merge!(:params => {:project_id => id})
          super(*options)
        elsif options.empty?
          issues =  RedmineAPI::Issue.find(:all, :params => {:project_id => id}).collect { |issue| TicketMaster::Provider::Redmine::Ticket.new issue }
        else
          super(*options)
        end
        rescue
          []
        end
      end
    end
  end
end
