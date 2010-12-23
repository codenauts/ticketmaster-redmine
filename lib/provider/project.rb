module TicketMaster::Provider
  module Redmine
    # Project class for ticketmaster-yoursystem
    # 
    # 
    class Project < TicketMaster::Provider::Base::Project
      # declare needed overloaded methods here
      API = RedmineAPI::Project      
      
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
        if options.first.is_a? Hash
          options[0].merge!(:params => {:project_id => id})
        elsif options.empty?
          RedmineAPI::Issue.find(:all, :params => {:project_id => id})
        end
        super(*options)
      end

    end
  end
end
