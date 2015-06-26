SET foreign_key_checks = 0;
DROP TABLE IF EXISTS opinion;
DROP TABLE IF EXISTS dialog;
SET foreign_key_checks = 1;

CREATE TABLE dialog (
   dialog_id int NOT NULL AUTO_INCREMENT,
   table_id int,
   speaker_id varchar(10),
   utterance text,
   comment text COMMENT 'Ademir\'s comment on utterance',
   PRIMARY KEY(`dialog_id`)
);

CREATE TABLE opinion (
   opinion_id int NOT NULL AUTO_INCREMENT,
   dialog_id int NOT NULL,
   opt char(1) DEFAULT '1' COMMENT 'The option from the spreadsheet, normally pro/con',
   tag varchar(100),
   code int DEFAULT 0 COMMENT 'ENUM, opinon from -2 to 2, 4=dunno',
   PRIMARY KEY(`opinion_id`),
   CONSTRAINT `opinion_FK_1`
      FOREIGN KEY(`dialog_id`)
      REFERENCES `dialog` (`dialog_id`)
      ON DELETE CASCADE
);

-- vim: ts=3 sw=3 sts=3 expandtab :
