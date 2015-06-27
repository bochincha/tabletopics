#!/usr/bin/env python

# Normally an ORM should be used instead of connecting to a DB directly, an
# example of one is http://www.sqlalchemy.org/library.html#tutorials another is
# http://peewee.readthedocs.org/en/latest/index.html
# For now though, might be easier to stick to the basics
import MySQLdb

import csv
import re

# Read command line arguments
import getopt
import sys

# Prune the DB at the start?
prune = False;

# Table/group ID
table_id = 1

# The file we're reading in
csvfile = "Samplesheet.csv"

try:
	# Short option syntax: "hv:"
	# Long option syntax: "help" or "verbose="
	opts, args = getopt.getopt(sys.argv[1:], "t:f:hp", ["help", "prune"])

except getopt.GetoptError, err:
	# Print debug info
	print str(err)
	error_action

for option, argument in opts:
	if option in ("-h", "--help"):
		print """Import a dialog CSV file into the database, usage:

	-t <table id>
		[Required] Unique ID (int) to represent the discussion table/group

	-f <csv file>
		[Required] Export of the spreadsheet into the CSV file

	-p/--prune
		Clears all data in database before starting

Please note, this file was written quickly, designed without flexibility in mind, implemented in the most basic way practical, and was only tested on one sheet."""
		
	elif option == "-t":
		table_id = int(argument)
		
	elif option == "-f":
		csvfile = argument
		
	elif option in ("-v", "--prune"):
		prune = True

# Make sure the options were set
# ... skip for now

print "Importing data from %s for table %d"%(csvfile, table_id)

#
# Some formatting functions to standerdize what we throw into the DB
def formatSpeaker(speaker):
	return speaker.strip().lower()

def formatTag(str):
	return str.strip().lower()

def formatUtterance(str):
	return str.strip();

# http://stackoverflow.com/questions/372885/how-do-i-connect-to-a-mysql-database-in-python
db = MySQLdb.connect(  \
	host   = "localhost", # your host, usually localhost \
	user   = "root", \
	passwd = "somethingsimple", \
	db     = "ECASTv1")

# This cursor will execute all the queries you need
cur = db.cursor()

if prune:
	print "Purging all data in database"
	# Start off by clearing the DB.
	cur.execute("DELETE FROM dialog");
	cur.execute("ALTER TABLE dialog  AUTO_INCREMENT = 1") # This line mightn't work in sqlite
	cur.execute("ALTER TABLE opinion AUTO_INCREMENT = 1") # This line mightn't work in sqlite
	db.commit();



# Every opinion will have a dialog ID, this value will be set in the loop but
# will persist over many iterations
dialog_id = -1

with open(csvfile, 'rb') as csvfile:
	dialogs = csv.reader(csvfile, delimiter=',', quotechar='"')

	# The CSV is formatted in a human readable way, but also in a way that is
	# very difficult to machine read.  Thus, this code relies on some values
	# persisting through subsequent iterations

	speaker = "";

	for row,line in enumerate(dialogs):
		# Skip the first two lines, no data there
		if row<=1:
			continue 

		# If the first cell has content, consider this the start of a new line
		# of dialog
		if len(line[0]):

			#print "Processing dialog for %s"%(line[0])
			speaker   = db.escape_string(formatSpeaker(line[0]))
			utterance = db.escape_string(formatUtterance(line[1]))
			comments   = db.escape_string(line[7])

			try:
				# Save this dialog
				query = "INSERT INTO dialog (table_id, speaker_id, utterance, comments) VALUES(%d, '%s', '%s', '%s')"%(table_id, speaker, utterance, comments)
				cur.execute(query)
				db.commit()
			except:
				# Rollback in case there is any error
				print "Something went wrong inserting into dialog (line129)"
				db.rollback()
				exit(0);

			# Fetch the dialog ID that the DB generated.  Typically an ORM
			# would return this, and there may also be a better way of getting
			# it here.  But for now, just select the last generated ID.  Note,
			# this would be a bad option if this DB was being used concurrently
			cur.execute("SELECT max(dialog_id) FROM dialog")
			data = cur.fetchone()
			dialog_id = data[0]
			#print "Set new dialog_id=%d"%dialog_id
			if not dialog_id:
				print "Something went wrong!  No dialog ID"
				break;

		# Check to see if we have an opinion
		#print "%d:"%(row) + ', '.join(line)
		if len(line[2]) and len(line[3]):
			tag = db.escape_string(formatTag(line[2]))
			code = int(line[3])
			# Check to see if the importance column has something in it
			if len(line[6]):
				importance = int(line[6])
				# Save this dialog
				query1 = "INSERT INTO opinion (dialog_id, opt, tag, code, importance) VALUES(%d, 'A', '%s', %d, %d)"%(dialog_id, tag, code, importance)
				#print query
				cur.execute(query1)
				db.commit()
			else: 
				#Just save the dialog per original code
				query = "INSERT INTO opinion (dialog_id, opt, tag, code) VALUES(%d, 'A', '%s', %d)"%(dialog_id, tag, code)
				#print query
				cur.execute(query)
				db.commit()

		# Check to see if we have an opinion
		if len(line[4]) and line[5]:
			tag = db.escape_string(formatTag(line[4]))
			code = int(line[5])
			# Check to see if the importance column has something in it
			if len(line[6]):
				importance = int(line[6])
				# Save this dialog
				query2 = "INSERT INTO opinion (dialog_id, opt, tag, code, importance) VALUES(%d, 'B', '%s', %d, %d)"%(dialog_id, tag, code, importance)
				# Print query
				cur.execute(query2)
				db.commit()
			else:
				#Just save the dialog per original code
				query = "INSERT INTO opinion (dialog_id, opt, tag, code) VALUES(%d, 'B', '%s', %d)"%(dialog_id, tag, code)
				# Print query
				cur.execute(query)
				db.commit()


		#print "%d:"%(row) + ', '.join(line)


# vim:set et sw=4 ts=4 sts=0 noet:
