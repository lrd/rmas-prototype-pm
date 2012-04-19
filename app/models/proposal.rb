require 'savon'

class Proposal < ActiveRecord::Base

	include ActiveModel::Dirty

	before_create :assign_rmas_id
	after_save :rmas_event
	after_destroy :rmas_destroy

	before_save do
		@changed_fields = self.changed
	end

	def generate_rmas_id
		# generate a new rmas id
		"urn:rmas:kent:pmtool:#{SecureRandom.uuid}"
	end

	def assign_rmas_id
		self.rmas_id = generate_rmas_id()
		@new_rec = true
	end

	def rmas_event
		if @new_rec
			self.rmas_new
		else
			self.rmas_updated
		end
	end

	def rmas_new
		puts 'sending proposal_created message'

		# generate the message
		message = {
			:message_type => 'proposal_created',
			:entity => {
				:id => self.rmas_id,
				:title => self.title,
				:description => self.description
			}
		}

		send_message message

	end

	def rmas_updated
		
		puts 'sending proposal_updated message'

		message = {
			:message_type => 'proposal_updated',
			:entity => {
				:id => self.rmas_id
			}
		}

		unless @changed_fields.empty?
			@changed_fields.each do |field|
				message[:entity].store(field, self[field])
			end
			
			puts message

			send_message message
		end
	end

	def rmas_destroy
		puts 'sending proposal_deleted message'

		message = {
			:message_type => 'proposal_deleted',
			:entity => {
				:id => self.rmas_id
			}
		}

		send_message message
	end

	def send_message(message)

		client = Savon::Client.new do
			wsdl.document = 'http://129.12.9.208:6980/EventService?wsdl'
		end

		message['message_id'] = generate_rmas_id()

		message_json = ActiveSupport::JSON.encode(message)

		response = client.request :push_event do
			soap.body = { :message => message_json }
		end

		unless response.success?
			puts response.soap_fault
		end
	end

end
