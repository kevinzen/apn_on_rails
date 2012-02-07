module APN
  module Connection
    
    class << self
      
      # Yields up an SSL socket to write notifications to.
      # The connections are close automatically.
      # 
      #  Example:
      #   APN::Configuration.open_for_delivery do |conn|
      #     conn.write('my cool notification')
      #   end
      # 
      # Configuration parameters are:
      # 
      #   configatron.apn.passphrase = ''
      #   configatron.apn.port = 2195
      #   configatron.apn.host = 'gateway.sandbox.push.apple.com' # Development
      #   configatron.apn.host = 'gateway.push.apple.com' # Production
      #   configatron.apn.cert = File.join(rails_root, 'config', 'apple_push_notification_development.pem')) # Development
      #   configatron.apn.cert = File.join(rails_root, 'config', 'apple_push_notification_production.pem')) # Production
      def open_for_delivery(options = {}, &block)
        open(options, &block)
      end
      
      # Yields up an SSL socket to receive feedback from.
      # The connections are close automatically.
      # Configuration parameters are:
      # 
      #   configatron.apn.feedback.passphrase = ''
      #   configatron.apn.feedback.port = 2196
      #   configatron.apn.feedback.host = 'feedback.sandbox.push.apple.com' # Development
      #   configatron.apn.feedback.host = 'feedback.push.apple.com' # Production
      #   configatron.apn.feedback.cert = File.join(rails_root, 'config', 'apple_push_notification_development.pem')) # Development
      #   configatron.apn.feedback.cert = File.join(rails_root, 'config', 'apple_push_notification_production.pem')) # Production
      def open_for_feedback(options = {}, &block)
        options = {:cert => configatron.apn.feedback.cert,
                   :passphrase => configatron.apn.feedback.passphrase,
                   :host => configatron.apn.feedback.host,
                   :port => configatron.apn.feedback.port}.merge(options)
        open(options, &block)
      end
      
      private
      
      def open(options = {}, &block) # :nodoc:
        options = {:cert => configatron.apn.dev_cert,
                   :key => configatron.apn.dev_key,
                   :passphrase => configatron.apn.passphrase,
                   :host => configatron.apn.host,
                   :port => configatron.apn.port}.merge(options)

#        cert_param = options[:cert]
        
        # pass either a file or the name of the file.
#        case cert_param
#          when String
#            certificate = File.read(options[:cert])
#          when File
#        certificate = cert_param
#        end

        # hard code for testing
        key_file = File.join(RAILS_ROOT, 'config', 'rsapkey.pem')
        key = File.read(key_file)

        cert_file = File.join(RAILS_ROOT, 'config', 'cert.pem')
        cert = File.read(cert_file)

        aps_server = options[:host]
        
        context       = OpenSSL::SSL::SSLContext.new
        context.key   = OpenSSL::PKey::RSA.new(key)
        context.cert  = OpenSSL::X509::Certificate.new(cert)

#        ctx.key = OpenSSL::PKey::RSA.new(cert, options[:passphrase])
  
        socket        = TCPSocket.new(aps_server, 2195)
        ssl           = OpenSSL::SSL::SSLSocket.new(socket, context)
        ssl.sync      = true
        ssl.connect
  
        yield ssl, socket if block_given?
  
        ssl.close
        socket.close
      end
      
    end
    
  end # Connection
end # APN