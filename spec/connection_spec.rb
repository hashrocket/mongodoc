require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

# Resets for testing
module MongoDoc
  module Connection

    def reset
      @config_path = nil
      @configuration = nil
      @connection = nil
      @database = nil
      @host = nil
      @name = nil
      @options = nil
      @port = nil
      @strict = nil
    end

  end
end

describe "MongoDoc::Connection.Connections" do

  context "Non-rails environment" do

    it "does not see Rails" do
      Object.const_defined?('Rails').should be_false
    end

    it "default the configuration location to './mongodb.yml'" do
      MongoDoc::Connection.config_path.should == './mongodb.yml'
    end

    context "without a configuration" do
      let(:connection) { stub('connection') }

      before do
        MongoDoc::Connection.reset
        MongoDoc::Connection.stub(:connect).and_return(connection)
      end

      it "creates a default connection" do
        MongoDoc::Connection.should_receive(:connect).and_return(connection)
        MongoDoc::Connection.connection
      end

      it "creates a default database with strict false" do
        connection.should_receive(:db).with("mongo_doc", :strict => false)
        MongoDoc::Connection.database
      end
    end
  end

  context "Rails environment" do

    module FauxRails
      extend self

      def env
        'development'
      end

      def root
        Pathname.new('rails_root')
      end
    end

    before do
      Object.const_set('Rails', FauxRails)
    end

    after do
      Object.send(:remove_const, 'Rails')
    end

    it "sees Rails" do
      Object.const_defined?('Rails').should be_true
    end

    it "default the configuration location to Rails.root + '/config/mongodb.yml'" do
      MongoDoc::Connection.config_path.should == FauxRails.root + 'config/mongodb.yml'
    end

    context "without a configuration" do
      let(:connection) { stub('connection') }

      before do
        MongoDoc::Connection.reset
        MongoDoc::Connection.stub(:connect).and_return(connection)
      end

      it "creates a default connection" do
        MongoDoc::Connection.should_receive(:connect).and_return(connection)
        MongoDoc::Connection.connection
      end

      it "creates a default database with strict false" do
        connection.should_receive(:db).with("rails_root_development", :strict => false)
        MongoDoc::Connection.database
      end
    end
  end

  context ".verify_server_version" do
    let(:connection) { stub('connection') }

    it "raises when the server version is unsupported" do
      connection.stub(:server_version).and_return(Mongo::ServerVersion.new('1.3.1'))
      lambda { MongoDoc::Connection.send(:verify_server_version, connection) }.should raise_error(MongoDoc::UnsupportedServerVersionError)
    end

    it "returns when the server version is supported" do
      connection.stub(:server_version).and_return(Mongo::ServerVersion.new('1.3.2'))
      lambda { MongoDoc::Connection.send(:verify_server_version, connection) }.should_not raise_error(MongoDoc::UnsupportedServerVersionError)
    end
  end

  describe ".connect" do
    let(:connection) { stub('connection') }

    before do
      MongoDoc::Connection.stub(:verify_server_version)
    end

    it "creates a Mongo::Connection" do
      host = 'host'
      port = 'port'
      options = 'options'
      MongoDoc::Connection.stub(:host).and_return(host)
      MongoDoc::Connection.stub(:port).and_return(port)
      MongoDoc::Connection.stub(:options).and_return(options)
      Mongo::Connection.should_receive(:new).with(host, port, options).and_return(connection)
      MongoDoc::Connection.send(:connect)
    end

    it "raises NoConnectionError if the connection fails" do
      Mongo::Connection.stub(:new).and_return(nil)
      lambda { MongoDoc::Connection.send(:connect) }.should raise_error(MongoDoc::NoConnectionError)
    end

    it "verifies the connection version" do
      Mongo::Connection.stub(:new).and_return(connection)
      MongoDoc::Connection.should_receive(:verify_server_version)
      MongoDoc::Connection.send(:connect)
    end
  end
end
