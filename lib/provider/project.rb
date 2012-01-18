module TicketMaster::Provider
  module Redmine
    # Project class for ticketmaster-yoursystem
    # 
    # 
    class Project < TicketMaster::Provider::Base::Project
      # declare needed overloaded methods here
      API = RedmineAPI::Project      
      LIMIT = 100
      
      def self.find_for_page(page)
        API.find(:all, :params => { :limit => LIMIT, :page => page })
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
