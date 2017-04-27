require 'bluecat'
require 'hammer_cli'
require 'apipie_bindings'
require 'netaddr'
require 'pp'

module HammerCliBluecat
  class BluecatCommand < HammerCLI::AbstractCommand
    class SyncNetworkCommand < HammerCLI::AbstractCommand
      include HammerCliBluecat

      # TODO: Consider tftp_id as an option instead of magik-ing it.

      def execute
        # Get current domain identifiers...
        @domain_ids = domain_ids
        @location_ids = location_ids
        @organization_ids = organization_ids

        @tftp_id = tftp_id

        @catalog = {}

        # Build a list of subnet resources from Bluecat...
        bluecat do |client|
          client.ip4_networks(38537).map { |network| bluecat_to_foreman_catalog network }
            .each { |entry| add_to_catalog entry }
        end

        # Gather current Foreman subnets
        subnet_networks = foreman.resource(:subnets).call(:index, :per_page => 9999)['results'].map do |s|
          {
            :id => s['id'],
            :network => s['network'],
          }
        end

        # Mark catalog entries for update or deletion
        subnet_networks.each do |network|
          if @catalog.has_key?(network[:network])
            if has_changed network
              @catalog[network[:network]][:action] = 'update'
              @catalog[network[:network]][:id] = network[:id]
            end
          else
            @catalog[network[:network]] = {
              :id => network[:id],
              :action => 'delete'
            }
          end
        end

        process_catalog
        HammerCLI::EX_OK
      end

      def process_catalog
        @catalog.each do |network, entry|
          case entry[:action]
            when 'create'
              puts "Creating #{entry}.\n"
              foreman.resource(:subnets).call(:create, { :subnet => entry[:resource] })
            when 'update'
              puts "Updating #{entry}.\n"
              foreman.resource(:subnets).call(:update, { :id => entry[:id], :subnet => entry[:resource] })
            when 'delete'
              puts "#{entry} marked for deletion, skipping.\n"
          end
        end
      end

      # Stub to determine whether an update is required
      def has_changed(network)
        true
      end

      # Foreman response from Bluecat into a unit of work.
      def bluecat_to_foreman_catalog(network)
        cidr = NetAddr::CIDR.create(network[:ip_range])

        if network[:name]
          name = "#{network[:name]} (#{network[:ip_range]})"
        else
          name = network[:ip_range]
        end

        {
          :id => nil,
          :action => 'create',
          :resource => {
              :name => name,
              :network_type => 'IPv4',
              :network => cidr.network,
              :mask => cidr.wildcard_mask,
              :gateway => cidr.nth(1),
              :dns_primary => '152.1.14.14',
              :dns_secondary => '152.1.14.21',
              :ipam => 'None',
              :domain_ids => @domain_ids,
              :location_ids => @location_ids,
              :organization_ids => @organization_ids,
              :tftp_id => @tftp_id,
              :boot_mode => 'DHCP'
          }
        }
      end

      def add_to_catalog(entry)
        @catalog[entry[:resource][:network]] = entry
      end
    end

    subcommand 'sync-networks', "Sync Bluecat networks to Foreman subnets", HammerCliBluecat::BluecatCommand::SyncNetworkCommand
  end

  HammerCLI::MainCommand.subcommand 'bluecat', "Bluecat Address Manager Tools", HammerCliBluecat::BluecatCommand

  def bluecat
    username = HammerCLI::Settings.get(:bluecat, :username)
    password = HammerCLI::Settings.get(:bluecat, :password)

    client = Bluecat::Client.new(wsdl: HammerCLI::Settings.get(:bluecat, :wsdl))
    client.login(username, password)

    yield client

    client.logout
  end

  def foreman
    uri = HammerCLI::Settings.get(:foreman, :host)
    username = HammerCLI::Settings.get(:foreman, :username)
    password = HammerCLI::Settings.get(:foreman, :password)

    HammerCLI::Apipie::ApiConnection.new(
        :uri => uri,
        :username => username,
        :password => password,
        :api_version => '2')
  end

  def domain_ids
    foreman.resource(:domains).call(:index)['results'].map { |e| e['id'] }
  end

  def location_ids
    foreman.resource(:locations).call(:index)['results'].map { |e| e['id'] }
  end

  def organization_ids
    foreman.resource(:organizations).call(:index)['results'].map { |e| e['id'] }
  end

  def tftp_id
    1
  end
end
