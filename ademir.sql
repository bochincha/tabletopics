DROP TABLE IF EXISTS dialog;
DROP TABLE IF EXISTS opinion;

CREATE TABLE dialog (
   dialog_id int,
	table_id int,
   speaker_id varchar(10),
   utterance text,
   PRIMARY KEY(`dialog_id`)
);

CREATE TABLE opinon (
   opinion_id int,
   tag varchar(100),
   code int DEFAULT 0 COMMENT 'ENUM, opinon from -2 to 2, 4=dunno',
   PRIMARY KEY(`opinion_id`),
   CONSTRAINT `opinion_FK_1`
      FOREIGN KEY(`opinion_id`)
      REFERENCES `dialog` (`dialog_id`)
);
-- vim: ts=3 sw=3 sts=3 expandtab :
