DROP TABLE IF EXISTS opinion;
DROP TABLE IF EXISTS dialog;

CREATE TABLE dialog (
   dialog_id int NOT NULL,
   table_id int,
   speaker_id varchar(10),
   utterance text,
   comment text,
   PRIMARY KEY(`dialog_id`)
);

CREATE TABLE opinion (
   opinion_id int NOT NULL,
   dialog_id int NOT NULL,
   opt char(1) DEFAULT '1',
   tag varchar(100),
   code int DEFAULT 0,
   PRIMARY KEY(`opinion_id`),
   CONSTRAINT `opinion_FK_1`
      FOREIGN KEY(`dialog_id`)
      REFERENCES `dialog` (`dialog_id`)
      ON DELETE CASCADE
);

-- vim: ts=3 sw=3 sts=3 expandtab :
