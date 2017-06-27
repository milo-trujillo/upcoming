#!/usr/bin/env ruby
require 'optparse'
require 'date'
require 'yaml'
require 'mail'

Version = 1.0
CalFile = ENV["HOME"] + "/.upcoming"
From = "example@example.com"
Destination = "example@example.com"

def dateString(date)
	return "#{date.mon}/#{date.mday}/#{date.year}"
end

class Event
	attr_reader :date, :description

	def initialize(date, description)
		if( date.downcase == "tomorrow" )
			@date = Date.parse(Time.now.strftime("%Y/%m/%d")) + 1
		else
			@date = Date.parse(date)
		end
		@description = description

		# If user entered "Monday", make sure we use *next* Monday
		# not *previous* Monday.
		now = Date.parse(Time.now.strftime("%Y/%m/%d"))
		if( now > @date )
			@date += 7
		end
	end

	def to_s
		sprintf("%10s -- %s", dateString(@date), @description)
	end

	def send
		date = @date
		description = @description
		Mail.deliver do
			delivery_method :sendmail
			to Destination
			from From
			subject "Upcoming event '#{description}'"
			body "#{dateString(date)}:\n\n#{description}"
		end
	end
end

def addEvent(event)
	events = []
	# Create blank file if necessary
	if( not File.exists?(CalFile) )
		File.write(CalFile, "")
	end
	f = File.open(CalFile, "r+")
	f.flock(File::LOCK_EX)
	if( f.size > 0 )
		events = YAML.load(f.read())
	end
	events << event
	f.seek(0)
	f.write(YAML.dump(events))
	f.truncate(f.pos)
	f.close()
end

def getEvents()
	events = []
	unless( File.exists?(CalFile) )
		return events
	end
	f = File.open(CalFile, "r")
	f.flock(File::LOCK_EX)
	if( f.size > 0 )
		events = YAML.load(f.read())
	end
	f.close()
	return events
end

def printEvents()
	for event in getEvents()
		puts event.to_s
	end
end

def notifyEvents()
	today = dateString(Time.now)
	unless( File.exists?(CalFile) )
		return
	end
	notify = []
	store = []
	f = File.open(CalFile, "r+")
	f.flock(File::LOCK_EX)
	events = YAML.load(f.read)
	for event in events
		if( dateString(event.date) == today )
			notify << event
		else
			store << event
		end
	end
	f.seek(0)
	f.write(YAML.dump(store))
	f.truncate(f.pos)
	f.close()
	for event in notify
		event.send
	end
end

options = {}
parser = OptionParser.new do |opts|
	opts.banner = "Usage: #{$0} [options] [<date> <event>]"

	opts.on("-d", "--daemon", "Check for events and send appropriate email") do |d|
		options[:daemon] = true
	end

	opts.on("-v", "--version", "Print version and exit") do |v|
		puts "#{Version}"
		exit
	end

	opts.on("-p", "--print", "Print currently stored events") do |p|
		options[:print] = true
	end

	opts.on("-s", "--show", "Show currently stored events (same as -p)") do |s|
		options[:print] = true
	end
end.parse!

if( ARGV.size != 0 and ARGV.size != 2 )
	print parser.banner
	exit
end

if( options[:print] )
	printEvents()
end

if( ARGV.size == 2 )
	event = Event.new(ARGV[0], ARGV[1])
	addEvent(event)
	puts "Added event: #{event.to_s}"
end

if( options[:daemon] )
	notifyEvents()
end
