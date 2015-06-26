-- Turn off foreign keys, meaning I can delete any table without concern of
-- what's connected to it.  This is ordinarily a bad thing to do, but as I'm
-- deleting all the tables in in the db on the next line, it doesn't matter.
--
-- I shouldn't need this, but something wasn't working, it was late, I was
-- frustrated, so I added this to remove any blocks I had on deletion.
--
-- Note, that command is MySQL only.
SET foreign_key_checks = 0;


-- This deletes the table opinion if it exists, otherwise it does nothing.
--
-- I forget how standard this command is..  "DROP TABLE <table>" is standard
-- SQL, I forget if the "IF EXISTS" is though.. looks standard.
DROP TABLE IF EXISTS opinion;
DROP TABLE IF EXISTS dialog;

-- Re-activate foreign key check
SET foreign_key_checks = 1;

-- Create a table for the dialogs with it's ID set to AUTO_INCREMENT.
-- - The 'COMMENT' parameter (not the `comment` column) seems to not work so well
--   in SQLite
-- - The dialog_id is set to `NOT NULL`, which it sort of has to be.  This just
--   means that the ID's must always have values.
--
-- - The Speaker ID is a varchar(10), this is just a string (series of
--   characters) of max size 10.. You can set this number as high as you want.
--   After 255 though you should use a the "text" type
-- - The PRIMARY KEY line just specifies the primary key, this is needed so the
--   next table knows it's a primary key (as it associates it self with it with a
--   foreign key)
CREATE TABLE dialog (
   dialog_id int NOT NULL AUTO_INCREMENT,
   table_id int,
   speaker_id varchar(10),
   utterance text,
   comment text COMMENT 'Ademir\'s comment on utterance',
   PRIMARY KEY(`dialog_id`)
);

-- Some differences here, namely the CONSTRAINT.  All this does is sets up a
-- foreign key.  Basically this table knows that every row is associated with
-- one row from the dialog table.  It's a 1-to-many relationship, where one
-- dialog can have many opinions.
--
-- It also has the extra behaviour of a cascading delete, meaning if a dialog
-- is deleted, all the associated opinions should be automatically deleted.
-- (which is why I shouldn't need to turn off the foreign key check in the
-- first line.. but again, it was late..)
CREATE TABLE opinion (
   opinion_id int NOT NULL AUTO_INCREMENT,
   dialog_id int NOT NULL,
   opt char(1) DEFAULT '1' COMMENT 'The option from the spreadsheet, normally pro/con',
   tag varchar(100),
   code int DEFAULT 0 COMMENT 'ENUM, opinion from -2 to 2, 4=dunno',
   PRIMARY KEY(`opinion_id`),
   CONSTRAINT `opinion_FK_1`
      FOREIGN KEY(`dialog_id`)
      REFERENCES `dialog` (`dialog_id`)
      ON DELETE CASCADE
);


-- Uhh, just ignore these lines, their just options for my editor
-- vim: ts=3 sw=3 sts=3 expandtab :
