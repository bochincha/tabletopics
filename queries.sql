SELECT * FROM dialog;
SELECT * FROM opinion;

-- Attempts to replicate your spreadsheet
SELECT
 d.speaker_id AS speaker,
 SUBSTRING(d.utterance, 1, 30) AS utternace,
 o.opt,
 o.tag,
 o.code
  FROM dialog d INNER JOIN opinion o USING (dialog_id)
 ORDER BY d.dialog_id, opinion_id

-- Attempts to replicate your spreadsheet, but makes the 'code' readable
SELECT
 d.speaker_id AS speaker,
 SUBSTRING(d.utterance, 1, 30) AS utternace,
 o.opt,
 o.tag,
   CASE
      WHEN code <= 2 THEN code
      WHEN code = 3 THEN 'invalid'
      WHEN code = 4 THEN 'n/a'
      ELSE 'Unknown'
   END AS code
  FROM dialog d INNER JOIN opinion o USING (dialog_id)
 ORDER BY d.dialog_id, opinion_id

-- Attempts to replicate your spreadsheet, but makes the 'code' readable, and
-- groups the data, first by the speaker, then by the tag, and then by the code.
-- this also adds an additional column that counts how often those three occur,
-- so a count of how many times speaker had tag X
SELECT
 d.speaker_id AS speaker,
 SUBSTRING(d.utterance, 1, 30) AS utternace,
 o.opt,
 o.tag,
   CASE
      WHEN code <= 2 THEN code
      WHEN code = 3 THEN 'invalid'
      WHEN code = 4 THEN 'n/a'
      ELSE 'Unknown'
   END AS code,
   count(code) AS freq
 FROM dialog d INNER JOIN opinion o USING (dialog_id)
 GROUP BY speaker, tag, code
 ORDER BY d.dialog_id, opinion_id

-- Same as above, but filters the results based on the frequency.  This is
-- special because typically you'd use 'WHERE' to filter in SQL.  The reasing
-- I'm using 'HAVING' here is that you're filtering on groups, so it's a little
-- different.
SELECT
 d.speaker_id AS speaker,
 SUBSTRING(d.utterance, 1, 30) AS utternace,
 o.opt,
 o.tag,
   CASE
      WHEN code <= 2 THEN code
      WHEN code = 3 THEN 'invalid'
      WHEN code = 4 THEN 'n/a'
      ELSE 'Unknown'
   END AS code,
   count(code) AS freq
 FROM dialog d INNER JOIN opinion o USING (dialog_id)
 GROUP BY speaker, tag, code
 HAVING freq BETWEEN -2 AND 2
 ORDER BY d.dialog_id, opinion_id


-- Same as above, but a different filter.  here it's 
SELECT
 d.speaker_id AS speaker,
 SUBSTRING(d.utterance, 1, 30) AS utternace,
 o.opt,
 o.tag,
   CASE
      WHEN code <= 2 THEN code
      WHEN code = 3 THEN 'invalid'
      WHEN code = 4 THEN 'n/a'
      ELSE 'Unknown'
   END AS code,
   count(code) AS freq
 FROM dialog d INNER JOIN opinion o USING (dialog_id)
 WHERE opt='1'
 GROUP BY speaker, tag, code
 HAVING freq BETWEEN 0 AND 2
 ORDER BY d.dialog_id, opinion_id

-- vim: ts=3 sw=3 sts=3 expandtab :
